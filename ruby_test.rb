# Problem 1. Explain briefly what this code does, fix any bugs, then clean it up however you 
# like and write a unit test using Test::Unit to show that it works. Use shoulda gem for writing
# your tests and write them in context/shoulda style

def bracketed_list(values)
 temp=""
 temp += "["
 values.each {|val| temp += "#{val.to_s} "}
 temp += "]"
 return temp
end

# Problem 2. This is a piece of code found in a fictional Rails controller and model. 
#
# Point out any bugs or security problems in the code, fix them, and refactor the code to
# make it cleaner. Hint: think 'fat model, skinny controller'. Explain in a few sentences
# what 'fat model, skinny controller' means.
class CarsController
 def break_random_wheel
   @car = Car.find(:first, :conditions => "name = #{params[:name]} and user=#{params[:user_id]}")
   @wheels = @car.components.find(:all, :conditions => "type = 'wheel'")
   random_wheel =  (rand*4).round
   @wheels[random_wheel].break!
   @car.functioning_wheels -= 1
 end
end

class Car < ActiveRecord::Base
 has_many :components
end

class User < ActiveRecord::Base
end