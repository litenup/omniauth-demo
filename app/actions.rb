helpers do

  # def logged_in?
  #   !session[:user_id].nil?
  # end

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def current_user=(user)
    @current_user = user
    session[:user_id] = user.nil? ? user : user.id
  end

  def protected!
    if logged_in? != true
      halt [ 401, 'Not Authorized' ]
    end
  end

  def signed_in?
    !!current_user
  end

end

set(:auth) do |*roles|
  condition do
    unless signed_in? && roles.any? {|role| current_user.role.to_sym == role }
      redirect "/login", 303
    end
  end
end

get '/' do
  erb :index
end

get '/register' do
  erb :register
end

post "/register" do
  @identity = env['omniauth.identity']
  erb :register
end

get "/login" do
  erb :login
end

post '/auth/:name/callback' do

  # if authentication.nil?  create authentication (created without user) end
  # if signed_in?
  #   if authentication.user == current_user
  #     already linked
  #   else
  #     authentication.user = current_user
  #     save
  #   end
  # else (not signed in)
  #   if @authentication.user.present? (is this auth already linked to a user)
  #     self.current_user = @authentication.user
  #     sign in user
  #   else (this auth not linked to user)

  auth = request.env['omniauth.auth']
  @authentication = Authentication.find_with_omniauth(auth)
  if @authentication.nil?
    @authentication = Authentication.create_with_omniauth(auth)
  end
  if signed_in?
    if @authentication.user == current_user
      redirect to "/", notice: "You have already linked this account"
    else
      @authentication.user = current_user
      @authentication.save
      redirect to "/", notice: "Account successfully authenticated"
    end
  else # no user is signed_in
    if @authentication.user.present?
      self.current_user = @authentication.user
      redirect to "/", notice: "Signed in!"
    else
      if @authentication.provider == 'identity'
        u = User.find(@authentication.uid)
      else
        u = User.create_with_omniauth(auth)
      end
      u.authentications << @authentication
      self.current_user = u
      redirect to "/"
    end
  end
end

get '/auth/:provider/callback' do
  auth = request.env['omniauth.auth']
  @authentication = Authentication.find_with_omniauth(auth)
  if @authentication.nil?
    @authentication = Authentication.create_with_omniauth(auth)
  end
  if signed_in?
    if @authentication.user == current_user
      redirect to "/", notice: "You have already linked this account"
    else
      @authentication.user = current_user
      @authentication.save
      redirect to "/", notice: "Account successfully authenticated"
    end
  else # no user is signed_in
    if @authentication.user.present?
      self.current_user = @authentication.user
      redirect to "/", notice: "Signed in!"
    else
      if @authentication.provider == 'identity'
        u = User.find(@authentication.uid)
      else
        u = User.create_with_omniauth_others(auth)
        
      end
      u.authentications << @authentication
      self.current_user = u
      redirect to "/"
    end
  end
  # Log the authorizing user in.
  # self.current_user = @authentication.user
  # "<h1>Hi #{env['omniauth.auth']['info']['name']}!</h1><img src='#{env['omniauth.auth']['info']['image']}'><p>#{env['omniauth.auth']}</p>"
end

get '/auth/failure' do
  @error = "Invalid Credentials. Try again"
  erb :login
end

get "/logout" do
  session[:user_id] = nil
  session.clear
  redirect to "/"
end

get "/user/account", :auth => [:user, :admin] do
  "Your dashboard"
end

get "/manage/user", :auth => [:admin] do
  "Your dashboard"
end

# get('/logout') do
#   response.set_cookie('login', false)
#   response.set_cookie('user_id', nil)
#   redirect '/'
# end

# get '/tracks' do
#   @tracks = Track.all
#   erb :'tracks/index'
# end

# get '/login' do
#   erb :'logins/index'
# end

# get '/signup' do
#   @user = User.new
#   erb :'logins/new'
# end

# post '/signup' do
#   @user = User.new(
#     username: params[:username],
#     password: params[:password]
#   )
#   if @user.save
#     redirect '/login'
#   else
#     erb :'logins/new'
#   end
# end

# get '/tracks/new' do
#   @track = Track.new
#   erb :'tracks/new'

# end

# get '/tracks/:id' do
#   @track = Track.find params[:id]
#   @reviews = Review.where(:track_id => @track.id)
#   erb :'tracks/show'
# end

# post '/tracks' do
#   @track = Track.new(
#     title: params[:title],
#     url: params[:url],
#     author:  params[:author],
#     user_id: request.cookies['user_id']
#   )
#   if @track.save
#     redirect '/tracks'
#   else
#     erb :'tracks/new'
#   end
# end

# post '/votes' do
#   @vote = Vote.new(
#     track_id: params[:track_id],
#     user_id: request.cookies['user_id']
#   )
#   if @vote.save
#     redirect '/tracks'
#   else
#     "you already voted"
#   end
# end

# post '/reviews' do
#   @review = Review.new(
#     review: params[:review],
#     track_id: params[:track_id],
#     user_id: request.cookies['user_id']
#   )
#   if @review.save
#     redirect "/tracks/#{params[:track_id]}"
#   else
#     "you already reviewed this song"
#   end
# end

# post '/deletereviews' do
#   Review.find(params[:review_id]).destroy
#   redirect "/tracks/#{params[:track_id]}"
# end


# post '/login' do
#   if User.where(:username => params['username']).pluck(:password)[0] == params['password']
#     id = User.where(:username => params['username']).pluck(:id)[0]
#     response.set_cookie('login',true)
#     response.set_cookie('user_id', id)
    
#     @login_error = false
#     redirect '/tracks'
#   else
#     @login_error = true
#     erb :'logins/index'
#   end