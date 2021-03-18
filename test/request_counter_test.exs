defmodule RequestCounterTest do
  use ExUnit.Case


  def set_ip_count(ip, new_count) do
    :sys.replace_state(Requests, fn state -> %{state | ip => new_count} end)
  end
  
  describe "new/1" do
    test "counts the request when the user inserts a valid IPV4" do

      input = %{ip: "177.21.61.154", path: "/xxxxx", method: "xxxx"}
      ip = input.ip

      RequestCounter.new(input)
      assert RequestCounter.get(ip) == 1
    end
    
    test "counts the request when the user inserts a valid IPV6" do

      input = %{ip: "2001:0db8:85a3:0000:0000:8a2e:0370:7334", path: "/xxxxx", method: "xxxx"}
      ip = input.ip

      RequestCounter.new(input)
      assert RequestCounter.get(ip) == 1
    end

    test "gets an error when an invalid ip is provided" do
      input = %{ip: "177.4134134134.1341341", path: "/xxxxx", method: "xxxx"}
      assert RequestCounter.new(input) == {:error, :ip_is_not_valid}
    end

    test "when the requests limit is reached" do
      input = %{ip: "192.01.02.100"}

      RequestCounter.new(input)
      set_ip_count("192.01.02.100", 5)

      assert RequestCounter.new(input) == {:error, :limit_reached}
    end
 end

  describe "get/1" do
    test "gets the requests from the provided valid input" do
      input = %{ip: "177.21.62.154", path: "/xxxxx", method: "xxxx"}
      ip = input.ip
    
      assert RequestCounter.get(ip) == 0
      RequestCounter.new(input)
      assert RequestCounter.get(ip) == 1
    end
  end

end
