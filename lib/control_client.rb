# Communicate with the clearskies daemon over a local socket
#
# See protocol/control.md for documentation.

require 'socket'
require 'json'
require 'conf'

module ControlClient

  def self.issue command, *args
    connect if !@socket
    json = {
      type: command,
      args: args,
    }.to_json

    json.gsub! "\n", ''

    @socket.puts json

    JSON.parse @socket.gets, symbolize_keys: true
  end

  private
  def self.connect

    @socket = UNIXSocket.new Conf.control_path
    @socket.sync = true

    greeting = JSON.parse @socket.gets, symbolize_keys: true

    unless greeting[:service] == 'ClearSkies Control'
      abort "Invalid daemon service: #{greeting.inspect}"
    end

    unless greeting[:protocol] == 1
      abort "Incompatible daemon protocol version: #{greeting[:protocol].inspect}"
    end
  end
end
