require 'sqlite3'
require 'sinatra'
require 'sinatra/reloader'

## Database connection method
def db_query( sql )
    db = SQLite3::Database.new 'employee_db.sqlite3'
    db.results_as_hash = true
    puts '==============================='
    puts sql   # for debugging our SQL
    puts '==============================='
    result = db.execute sql
    db.close
    result  # return the result of the query
end

### CREATE RPUTES ###

get '/employees/add' do
    erb :new
end 

post '/employees' do 
    sql = "INSERT INTO employee( first_name, business_title, salary)
    VALUES(
      '#{ params[:first_name] }',
      '#{ params[:business_title] }',
      '#{ params[:salary] }'
    );"
    db_query sql
    redirect "/employees"
end  


### READ ROUTES ###

get '/employees' do
        @employees = db_query('select * from employee')
        erb :employees
end

get '/employees/:id' do 
    id = params['id'] 
    @employee = db_query("SELECT * FROM employee WHERE id = #{ params[:id] };")
    @employee.first
    erb :employee
end

### UPDATE ROUTES ###

# 1. Get the Employee
get '/employees/edit/:id' do
    @employee = db_query("SELECT * FROM employee WHERE id = #{ params[:id] };").first
    erb :employee_edit
end

#2. Update the Database
post '/employees/edit/:id' do
    # "#{params}"
    sql = "UPDATE employee SET
    first_name         = '#{ params[:first_name] }',
    business_title     = '#{ params[:business_title] }',
    salary             = '#{ params[:salary] }'
    WHERE id = #{ params[:id] };" 

    db_query sql

    redirect "/employees/#{ params[:id] }"   # redirect to the show (details) page for this employees
end 

### Delete Routes ####

get '/employees/:id/delete' do
    db_query "DELETE FROM employee WHERE id = #{ params[:id] }"
    redirect "/employees"   # No template to show, redirect to the index
end