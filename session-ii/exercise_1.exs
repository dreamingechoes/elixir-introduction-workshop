defmodule Fibonacci do
  def fib(number) when number <= 1, do: number

  def fib(number) do
    fib(number - 1) + fib(number - 2)
  end
end

IO.inspect(Fibonacci.fib(8))
