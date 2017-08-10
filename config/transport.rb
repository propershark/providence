Transport.configure do |config|
  config.wamp = {
    uri: 'ws://127.0.0.1:8080/ws/',
    realm: 'realm1',
    authid: 'tester2',
    authmethods: ['anonymous']
  }
end
