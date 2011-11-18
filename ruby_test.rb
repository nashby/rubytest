# Instructions for this test:
# 1. Please clone this gist as a git repo locally
# 2. Create your own github repo called 'rubytest' (or a name of your choice) and add this repo as a new remote to the cloned repo
# 3. Edit this file to answer the questions, and push this file with answers back out to your own 'rubytest' repo.

# Problem 1. Explain briefly what this code does, fix any bugs, then clean it up however you
# like and write a unit test using RSpec.

# this method iterate through an array and return the string representation of it

def bracketed_list(values)
 temp=""
 temp += "["
 values.each {|val| temp += "#{val.to_s}, "}
 temp += "]"
 return temp
end

def my_bracketed_list_1(values)
  "#{values}" # actually, it calls values.inspect under the hood
end

def my_bracketed_list_2(values)
  "[#{values.join(', ')}]"
end

def my_bracketed_list_3(values)
  values.to_s
end

describe "my_bracketed_list_1" do
  it 'return the string representation of the array' do
    my_bracketed_list_1([1, 2, 3, 4, 5]).should == "[1, 2, 3, 4, 5]"
  end
end

describe "my_bracketed_list_2" do
  it 'return the string representation of the array' do
    my_bracketed_list_2([1, 2, 3, 4, 5]).should == "[1, 2, 3, 4, 5]"
  end
end

describe "my_bracketed_list_3" do
  it 'return the string representation of the array' do
    my_bracketed_list_3([1, 2, 3, 4, 5]).should == "[1, 2, 3, 4, 5]"
  end
end

# Problem 2. This is a piece of code found in a fictional Rails controller and model.
#
# Point out any bugs or security problems in the code, fix them, and refactor the code to
# make it cleaner. Hint: think 'fat model, skinny controller'. Explain in a few sentences
# what 'fat model, skinny controller' means.

# 1. this code has a place with a potential sql-injection in this line :condition => "name = '#{params[:name]}' and user='#{params[:user_id]}'
# 2. we can't use 'type' as a db column name in rails because it reserved for STI models (it's better to rename it to 'kind' or something like that)
# 'fat model, skinny controller' means that we move our buisness logic from controller to the model. It increases maintainability a lot.

class CarsController < ApplicationController
 before_filter :find_user

 def break_random_wheel
   @car = @user.cars.find_by_name!(params[:name])
   @car.break_random_wheel
 end

 private
  def find_user
    @user = User.find(params[:user_id])
  end
end

class Car < ActiveRecord::Base
  has_many :components, :dependent => :destroy

  belongs_to :user

  def break_random_wheel
    self.class.transaction do
      components.wheels.sample.try(:break!) # sample if ruby 1.9 or choice for 1.8
      self.class.decrement_counter(:functioning_wheels, id)
    end
  end
end

class User < ActiveRecord::Base
  has_many :cars, :dependent => :destroy
end

сlass Component < ActiveRecord::Base
  belongs_to :car

  scope :wheels, where(:kind => 'wheel')
end

# Problem 3. You are running a Rails application with 2 workers (imagine a 2-mongrel cluster or a Passenger with 2 passenger workers).
# You have code that looks like this

class CarsController
 def start_engine
  @car = Car.first # in this line we don't know which car .first method will return. we should use :order => created_at DESC for example
  @car.try(:start_engine) # because Car.first can return nil
 end
end

class Car
 def start_engine
  api_url = "http://my.cars.com/start_engine?id={self.id}"
  RestClient.post api_url
 end
end

# 3a. Explain what possible problems could arise when a user hits this code.

# with this code we can post in parallel with the same id to this api that can be not good.

# 3b. Imagine now that we have changed the implementation:

class CarsController
  def start_engine
    sleep(30)
  end

  def drive_away
    sleep(10)
  end

  def status
    sleep(5)
    render :text => "All good!"
  end
end

# Continued...Now you are running your 2-worker app server in production.
#
# Let's say 5 users (call them x,y,z1,z2,z3), hit the following actions in order, one right after the other.
# x: goes to start_engine
# y: goes to drive_away
# z1: goes to status
# z2: goes to status
# z3: goes to status
#
# Explain approximately how long it will take for each user to get a response back from the server.
#
# Example: user 'x' will take about 30 seconds. What about y,z1,z2,z3?
#
# Approximately how many requests/second can your cluster process for the action 'start_engine'? What about 'drive_away'?
# What could you do to increase the throughput (requests/second)?

# user x will take about 30 seconds
# user y will take 10 seconds
# user z1 will take 15 seconds
# user z2 will take 20 seconds
# user z3 will take 25 seconds

# For the action 'start_engine' cluster can process about 0.067 requests/seconds
# For the action 'drive_away' cluster can process about 0.2 requests/seconds

# You can increase the throughput by:
# 1. adding more workers
# 2. move these jobs to background (using delayed_job gem for example)
# 3. use some event-processing library( event_machine for example)

# Problem 4. Here's a piece of code to feed my pets. Please clean it up as you see fit.

my_pets = [Cat.new, Dog.new, Cow.new]

my_pets.map { |pet| pet.feed(pet.class.favorite_food) }

class Pet
  class << self
    def favorite_food
      class_variable_get('@@favorite_food') # similar to cattr_reader but with inheritance
    end
  end

  def feed(food)
    puts "thanks!" if food == self.class.favorite_food
  end
end

class Cat < Pet
  @@favorite_food = :milk
end

class Dog < Pet
  @@favorite_food = :dogfood
end

class Cow < Pet
  @@favorite_food = :grass
end

# Problem 5. Improve this code

class ArticlesController < ApplicationController
 def index
  @articles = Article.send(params[:state]) if Article::STATES.include?(params[:state]) # if we want to get different kinds of states depends on params[:state]
 end
end

class Article < ActiveRecord::Base
  STATES.each do |key, value|
    scope key, { where(:state => value, :order => "created_at DESC") }
  end
end

# Problem 6. Explain in a few sentences the difference between a ruby Class and Module and when it's appropriate to use either one.

# The main difference is you can use include and extend with Module. So you can implement a multiple inheritance for example.
# You can't create an instance of Module.
# You can inherit one class from another but you can't do it with modules
# Actually, Class inherits from Module

# Problem 7. Explain the problem with this code

# in this code we fetch all users and then select which are active. It will be a big problem(it will use a lot of memory for
# example) if users count is a big number. The second problem is select will return our records instead of ActiveRecotd
# relation so it will load all our users in the controller and it is not good.
# we should use User.where(:active => true) or something like this

class UsersController
 def find_active_users
   User.where(:active => true) #returns AR relation
 end
end

# Problem 8. Explain what's wrong with this code and fix it. (Hint: named_scope)

# the main problem is we can't chaining these methods. We should use relations for this.
class User < ActiveRecord::Base
  has_many :cars, :dependent => :destroy
end

class Car < ActiveRecord::Base
  belongs_to :user

  scope :red, { where(:color => :red) }
  scope :green, { where(:color => :green) }
end

# Problem 9. Here's a piece of code that does several actions. You can see that it has duplicated
# error handling, logging, and timeout handling. Design a block helper method that will remove
# the duplication, and refactor the code to use the block helper.

def log_action(logger, info, timeout_time)
  raise ArgumentError, 'you should pass block' unless block_given?
  logger.info(info)
  Timeout::timeout(timeout_time) do
   begin
    yield
   rescue => e
    logger.error "Got error: #{e.message}"
   end
  end
end

log_action(logger, "About to do action1", 5) { action1 }
log_action(logger, "About to do action2", 10) { action2 }
log_action(logger, "About to do action3", 7) { action3 }