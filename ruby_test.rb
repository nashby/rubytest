# Problem 1. Explain briefly what this code does, fix any bugs, then clean it up however you 
# like and write a unit test using Test::Unit to show that it works

def bracketed_list(values)
 temp=""
 temp += "["
 values.each {|val| temp += "#{val.to_s} "}
 temp += "]"
 return temp
end

