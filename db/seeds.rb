USERS = [
  { email: 'agustin@winguweb.org', password: 'nadanada', password_confirmation: 'nadanada'},
  { email: 'facundo@winguweb.org', password: 'nadanada', password_confirmation: 'nadanada'},
  { email: 'carlos@winguweb.org', password: 'nadanada', password_confirmation: 'nadanada'},
  { email: 'constanza@winguweb.org', password: 'nadanada', password_confirmation: 'nadanada'},
]
User.where(email: USERS.map{ |data| data[:email] }).destroy_all
USERS.each do |data|
  user = User.create!(data)
end
