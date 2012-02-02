#!/usr/bin/env ruby
# The MIT License
#
# Copyright (c) 2012 Michael V. O'Brien.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'rubygems'

require 'ostruct'
require 'optparse'
require 'tempfile'

VERSION = "0.1.0"

BOLD = `tput bold`
RED = `tput setaf 1`
GREEN = `tput setaf 2`
YELLOW = `tput setaf 3`
BLUE = `tput setaf 4`
RESET = `tput sgr0`

@_settings = OpenStruct.new
@_settings.noop = false
@_settings.interactive = false

def _diff(first, second)
  left, right = Tempfile.new('ct'), Tempfile.new('ct')

  begin
    left.write(first)
    left.flush
    right.write(second)
    right.flush
    diff_str = `git diff --color #{left.path} #{right.path} | sed 1,4d`
  ensure
    left.close
    left.unlink
    right.close
    right.unlink
  end

  diff_str
end

def _write_file(path, content)
  return nil if noop?
  File.open(path, 'w') do |f|
    f.write(content)
  end
end

def _print_script(script)
  puts "#{YELLOW}{"
  lines = script.split("\n")
  indentation = (lines.first.slice(/^ +/) || "").length

  lines.each do |line|
    puts line.gsub(/^.{#{indentation}}/, '  ')
  end
  puts "}#{RESET}"
end

def noop?
  @_settings.noop
end

def info(text)
  puts "#{YELLOW}==>#{RESET} #{BOLD}#{text}#{RESET}"
end

def error(text)
  puts "#{RED}==>#{RESET} #{BOLD}#{text}#{RESET}"
end

def sh_out(commands)
  _print_script commands
  Kernel.system(commands) unless noop?
end

def sh_exitstatus(commands)
  `#{commands}`
  $?.exitstatus == 0
end

def file(path, content)
  original = ""
  if File.exists?(path)
    original = File.read(path)
  end

  diff_str = _diff(original, content)
  unless diff_str.empty?
    info "[DO] Write #{path}"
    puts diff_str
    _write_file(path, content)
  else
    info "[SKIP] Write #{path}"
  end
end

def script(description, should_run, commands)
  if should_run
    info "[DO] #{description.capitalize}"
    sh_out commands
  else
    info "[SKIP] #{description.capitalize}"
  end
end

def _installed?(name)
  sh_exitstatus "brew list | grep -q -e '^#{name}$'"
end

def _install(name)
  sh_out "brew install #{name}"
end

def _outdated?(name)
  sh_exitstatus "brew outdated | grep -q -e '^#{name}$'"
end

def _upgrade(name)
  sh_out "brew upgrade #{name}"
end

def package(name)
  if _installed? name
    if _outdated? name
      info "[DO] Upgrade #{name}"
      _upgrade name
    else
      info "[SKIP] Install #{name}"
    end
  else
    info "[DO] Install #{name}"
    _install name
  end
end

OptionParser.new do |opts|
  opts.banner = "Usage: ct [options] [file]"

  opts.on("-n", "--noop", "Run in no operation mode") do |n|
    @_settings.noop = n
  end
  opts.on("-i", "--interactive", "Run in interactive mode") do |i|
    @_settings.interactive = i
  end
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
  opts.on_tail("--version", "Show version") do
    puts VERSION
    exit
  end
end.parse!

if @_settings.interactive
  require 'irb'
  require 'irb/completion'
  ARGV.clear

  IRB.setup(nil)
  IRB.conf[:PROMPT_MODE] = :SIMPLE
  irb = IRB::Irb.new
  IRB.conf[:MAIN_CONTEXT] = irb.context

  trap("SIGINT") do
    irb.signal_handle
  end

  begin
    catch(:IRB_EXIT) do
      irb.eval_input
    end
  ensure
    IRB.irb_at_exit
  end
else
  eval ARGF.read
end
