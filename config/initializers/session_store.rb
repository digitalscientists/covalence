# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_covalence_session',
  :secret      => 'f9d97c55f0e298518f08cfff24649880c2971401ee6c45fa9255421b156f175e3f047c04ca4208674c9cce25e41201328548b248203859a2dacb626d6aadb1a6'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
