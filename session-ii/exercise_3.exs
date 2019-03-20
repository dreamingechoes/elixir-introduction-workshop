defmodule Calculator do
  def sum(argument) when is_list(argument), do: Enum.sum(argument)
  def sum(num1, num2), do: num1 + num2
  def sub(num1, num2), do: num1 - num2
  def mult(num1, num2), do: num1 * num2
  def div(_num1, 0), do: "ERROR!"
  def div(num1, num2), do: num1 / num2
end

IO.inspect(Calculator.sum([1, 2, 3, 4]))
IO.inspect(Calculator.sum(5, 6))
IO.inspect(Calculator.sub(10, 3))
IO.inspect(Calculator.mult(6, 8))
IO.inspect(Calculator.div(6, 0))
IO.inspect(Calculator.div(6, 2))
