TinyAesView = require '../lib/tiny-aes-view'

describe "TinyAesView", ->
  it "has one valid test", ->
    expect("life").toBe "life"

# before the dialog becomes visible, the fields are empty
# after the dialog becomes invibisbile, the fields are empty
# you cannot show the dialog twice in a row
# you cannot hide / cancel / submit the dialog twice in a row
# password mismatches are caught
# cancels work properly
# decryprion of known ciphertext works
# encryption then decryption of random ciphertext / password works
