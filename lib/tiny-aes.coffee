{PasswordDialogView} = require './tiny-aes-view'
{CompositeDisposable} = require 'atom'

####################
# Helper Functions #
####################

TinyAES =
  subscriptions: null
  encryptView: null
  decryptView: null

  activate: (state) ->
    @encryptView = new PasswordDialogView atom.workspace, 'encrypt'
    @decryptView = new PasswordDialogView atom.workspace, 'decrypt'

    # Events subscribed to in atom's system can be easily
    # cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register encryption / decryption commands.
    @subscriptions.add atom.commands.add 'atom-text-editor',
      'tiny-aes:encrypt': => @encrypt()
    @subscriptions.add atom.commands.add 'atom-text-editor',
      'tiny-aes:decrypt': => @decrypt()

  deactivate: ->
    @subscriptions.dispose()
    @encryptView.destroy()
    @decryptView.destroy()

  serialize: ->

  encrypt: ->
    selection = @getSelectionOrEverything()
    @encryptView.requestPassword()
    .then (pw) =>
      script = "openssl enc -e -aes128 -base64 -pass \"pass:#{pw}\""
      @exec script, input: selection.getText()
    .then (cyphertext) =>
      selection.insertText cyphertext, select:yes
    .catch (err) =>
      console.log err
      return if err.message == "Cancelled."
      console.log err.stack
      atom.notifications.addWarning err.message

  decrypt: ->
    selection = @getSelectionOrEverything()
    @decryptView.requestPassword()
    .then (pw) =>
      script = "openssl enc -d -aes128 -base64 -pass \"pass:#{pw}\""
      @exec script, input: selection.getText()
      .catch (err) => Promise.reject Error 'Password incorrect.'
    .then (cleartext) =>
      selection.insertText cleartext, select:yes
    .catch (err) =>
      console.log err
      return if err.message == "Cancelled."
      console.log err.stack
      atom.notifications.addWarning err.message

  # Execute something on the command line, returning a promise.
  # cmd: (string) the cmd to execute
  # options: list of options
  #   input: (string) piped into stdin
  exec: (cmd, options) ->
    new Promise (resolve, reject) ->
      childProcess = require 'child_process'
      child = childProcess.exec cmd, (err, stdout, stderr) ->
        if err then reject err else resolve stdout
      child.stdin.write(options?.input ? '')
      child.stdin.end()

  # The current selection or selects everything.
  getSelectionOrEverything: ->
    editor = atom.workspace.getActiveTextEditor()
    selection = editor.getLastSelection()
    selection.selectAll() if selection.isEmpty()
    return selection

module.exports =
    activate: (state) -> TinyAES.activate state
    deactivate: -> TinyAES.deactivate
    serialize: -> TinyAES.serialize
