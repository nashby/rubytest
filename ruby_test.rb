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

# Problem 3. You are running a Rails application with 2 workers (imagine a 2-mongrel cluster or a Passenger with 2 passenger workers). 
# You have code that looks like this

class CarController
 def start_engine
  @car.start_engine!
 end
end

class Car
 def start_engine!
  api_url = "http://my.cars.com/start_engine?id={self.id}"
  RestClient.post api_url
 end
end

# 3a. Explain what possible problems could arise when a user hits this code.
# 3b. Imagine now that we have changed the implementation:

class Car
 def start_engine!
  sleep(30)
 end
end

# Let's say 3 users hit this action at the same time (call them x,y,z). Explain approximately how long it will take 
# for each user to get a response back from the server. Example: user 'x' will take about 30 seconds. What about y and z?
# How many "requests/second" can your cluster process? What could you do to increase the throughput (requests/second)?


# Problem 4. Here's a piece of code to feed my pets. Please clean it up as you see fit.

cat = Cat.new
dog = Dog.new
cow = Cow.new
my_pets = [cat, dog, cow, ]

my_pets.each do |pet|
 if pet.is_a?(Cat)
   pet.feed(:milk)
 elsif pet.is_a?(Cow)
   pet.feed(:grass)
 elsif pet.is_a?(Dog)
   pet.feed(:dogfood)
 end
end

class Pet
 def feed(food)
   puts "thanks!"
 end
end

class Cat < Pet
end

class Dog < Pet
end

class Cow < Pet
end
