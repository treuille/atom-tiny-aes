$ = require('jquery')

module.exports =
  PasswordDialogView: class PasswordDialogView
    # Constructs a PasswordDialogView.
    # type - either 'encrypt' or 'decrypt'
    # workspace - where to add the modal panel containing this
    constructor: (@workspace, @type) ->
      # no password has been requested
      @promise = null

      # create the html element
      @element = $ '<div class="tiny-aes-view">'
      labels = switch @type
        when 'encrypt' then ['Password:', 'Retype Password:']
        when 'decrypt' then ['Password:']
        else throw Error('Type must be "encrypt" or "decrypt".')
      for index, label of labels
        @element.append $('<div class="password-input-row">').append $ """
          <span class="password-label">#{label}</span>
          <input class="password-input" id="pw#{index}", type="password">
        """

      # add the element to the workspace
      @panel = @workspace.addModalPanel item: @element, visible: false

      # wire in some event handlers
      @panel.onDidChangeVisible (visible) => @onVisibilityChange visible
      @element.find('.password-input').keydown (event) => @onKeydown event

    # Returns an object that can be retrieved when package is activated.
    serialize: ->

    # Tear down any state and detach.
    destroy: ->
      @element.remove()
      @panel.destroy()

    # Returns a promise of the password.
    requestPassword: ->
      if @promise?
        throw Error 'Cannot request promise twice.'
      @panel.show()
      @promise = new Promise (resolve, reject) => setImmediate =>
        @promise.resolve = resolve
        @promise.reject = reject

    # Submits the password and closes the panel.
    submit: ->
      {resolve,reject} = @removePromise()
      # get the password and hide the panel
      passwords = ($(el).val() for el in @element.find 'input')
      @panel.hide()

      # check if passwords match and returning
      if (@type is 'encrypt') and (passwords[0] != passwords[1])
        reject Error "Passwords don't match."
      else
        resolve passwords[0]

    # Closes the panel without submitting the password.
    cancel: ->
      # remove the promise
      {resolve,reject} = @removePromise()
      @panel.hide()
      reject Error 'Cancelled.'

    # Places focus on the named element in the panel.
    focus: (id) ->
      @element.find("\##{id}").focus()

    # Called when panel visibiliy changes.
    onVisibilityChange: (becameVisible) ->
      if becameVisible
        @focus 'pw0' # focus on the first input
      else
        @element.find('.password-input').val('') # clear inputs
        $(atom.views.getView(atom.workspace)).focus() # focus the editor

    onKeydown: (event) ->
      id = $(event.target).attr 'id'
      switch event.keyCode
        when 9 # TAB
          if id is 'pw1' then @focus 'pw0'
        when 13 # ENTER
          if (@type is 'decrypt') or (id is 'pw1') then @submit()
          else @focus 'pw1'
        when 27 # ESCAPE
          @cancel()

    # Removes (and returns) the promise.
    removePromise: ->
      unless @promise? then throw Error 'No promise to remove.'
      [p, @promise] = [@promise, null]
      return p
