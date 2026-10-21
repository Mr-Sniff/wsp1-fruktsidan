require 'debug'
require "awesome_print"

class App < Sinatra::Base
  register Sinatra::Reloader

  def db
    return @db if @db

    @db = SQLite3::Database.new(DB_PATH)
    @db.results_as_hash = true

    return @db
  end

  #TODO: Skriv routen hämtar alla frukter i databasen
  get '/fruits' do
    @fruits = db.execute("SELECT * FROM products ORDER BY name")
    ap @fruits
    erb :"fruits/index"
  end

  get '/fruits/new' do
    @categories = db.execute("SELECT * FROM categories ORDER BY name")
    ap @categories
    erb :"fruits/new"
  end

  post '/fruits' do
    ap params
    name = params["fruit_name"]
    desc = params["fruit_description"]
    rating = params["rating"]
    category = params["category_id"]
    db.execute("INSERT INTO products (name, description, tastiness, category_id) VALUES (?, ?, ?, ?)", [name, desc, rating.to_i.clamp(0, 10), category])
    redirect('/fruits')
  end

  get '/fruits/:id' do | id |
    @fruit = db.execute('SELECT * FROM products WHERE id=?',id).first
    ap @fruit
    erb(:"fruits/show")
  end

  post '/fruits/:id/delete' do | id |
    db.execute("DELETE FROM products WHERE id =?", id)
    redirect("/fruits")
  end


  get '/fruits/:id/edit' do | id |
    @fruit = db.execute('SELECT * FROM products WHERE id=?',id).first
    ap @fruit
    @categories = db.execute("SELECT * FROM categories ORDER BY name")
    ap @categories
    erb :"fruits/edit"
  end


  post "/fruits/:id/update" do | id |
    f_name = params["fruit_name"]
    f_category = params["fruit_description"]
    f_taste = params["taste"]
    f_category = params["category_id"]
    ap params
    db.execute("UPDATE products
      SET name =?, description=?, tastiness=?, category_id=? WHERE id =?", [f_name, f_category, f_taste.to_i.clamp(0, 10), f_category, id])

    redirect("/fruits")
  end

  get '/categories' do
    @categories = db.execute("SELECT * FROM categories ORDER BY name")
    ap @categories
    erb :"categories/index"
  end

  get '/categories/:id' do |id|
    @category = db.execute("SELECT * FROM categories WHERE id =?", id).first
    ap @category
    @fruits = db.execute("SELECT * FROM products WHERE category_id =?", id)
    ap @fruits
    erb :"categories/show"
  end

end
