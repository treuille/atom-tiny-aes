asjdfa$ = require('jquery')

module.exports =
  PasswordDialogView: class PasswordDialogView
    # Constructs a PasswordDialogView.
    # type - either 'encrypt' or 'decrypt'
    # workspace - where to add the modal panel containing this
    constructor: (@workspace, @type) ->
      # create the html element
      @element = $('<div class="tiny-aes-view">')
      labels = switch @type
        when 'encrypt' then ['Password:']
        when 'decrypt' then ['Password:', 'Retype Password:']
        else throw Error('Type must be "encrypt" or "decrypt".')
      for index, label of labels
        @element.append $('<div class="password-input-row">').append $ """
          <span class="password-label">#{label}</span>
          <input class="password-input" id="pw#{index}", type="password">
        """

      # add the element to the workspace
      @panel = @workspace.addModalPanel item: @element, visible: false
      @panel.onDidChangeVisible (becameVisible) ->
        console.log "onDidChangeVibible #{becameVisible}"

      # # a tiny html element generator
      # el = (type, attr, children...) ->
      #   console.log "el type:#{type} attr:#{attr} children:#{children}"
      #   element = document.createElement type
      #   for key, value of attr
      #     console.log "setting attribute '#{key}':'#{value}'"
      #     element.setAttribute key, value
      #   console.log 'finished setting atributes'
      #   for child in children
      #     if typeof child is 'string'
      #       element.innerHTML = child
      #     else
      #       element.appendChild child
      #   return element

        # if children = contents?() # contents == function
        #   console.log "el #{type} #{htmlClass}"
        #   console.log children
        #   console.log(child) for child in children
        #
        # else if contents? # contents was a string with the text
        #   element.innerHTML = contents
        # return element

      # @element = el('div', class:'tiny-aes-view',
      #   el('div', class:'password-input-row',
      #     el('span', class:'password-label', 'Password:'),
      #     el('input', class:'password-input', type:'password')
      #   ),
      #   el('div', class:'password-input-row',
      #     el('span', class:'password-label', 'Retype Password:'),
      #     el('input', class:'password-input', type:'password')
      #   )
      # )
      # #   el 'div', class:'password-input-row', [
      #   ]
      # ]

      #  -> [
      #
      #     (),
      #     ()
      #   ]
      # ]

      # html = """
      # <div class="tiny-aes-view">
      #   <div class="password-input-row">
      #     <span class="password-label">
      #       Password:
      #     </span>
      #     <input class="password-input" id="password-1" type="password">
      #   </div>
      #   <div class="password-input-row">
      #     <span class="password-label">
      #       Retype Password:
      #     </span>
      #     <input class="password-input" id="password-2" type="password">
      #   </div>
      # </div>
      # """



    # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
      @element.remove()
      @panel.destroy()

    show: -> @panel.show()

    hide: -> @panel.hide()

    isVisible: -> @panel.isVisible()
