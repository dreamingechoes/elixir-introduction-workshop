defmodule NoCase do
  def check(%{name: name}), do: IO.inspect("Your name is #{name}")
  def check(argument) when is_integer(argument), do: IO.inspect("You have #{argument} apples")

  def check(argument) when is_list(argument),
    do: IO.inspect("The sum of the elements is #{Enum.sum(argument)}")

  def check(_), do: IO.inspect("I don't know what you say")
end

NoCase.check(%{name: "Iván"})
NoCase.check(10)
NoCase.check([3, 4, 5, 6])
NoCase.check("Hello")
