defmodule Fibonacci do
  def fib(0), do: 0
  def fib(1), do: 1
  
  def fib(number) do
    fib(number - 1) + fib(number - 2)
  end
end

IO.inspect(Fibonacci.fib(8))
