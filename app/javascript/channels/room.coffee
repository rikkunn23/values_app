App.room = App.cable.subscriptions.create "RoomChannel",
  connected: ->
    # 通信が確立された時の処理

  disconnected: ->
    # 通信が切断された時の処理

  received: (data) ->
    # データが送信されてきた時の処理

  speak: (message) ->
    # channelのspeakアクションにmessageパラメータを渡す
    @perform 'speak', message: message

# チャットを送る
$(document).on 'keypress', '[data-behavior~=room_speaker]', (event) ->
  # return(Enter)が押された時
  if event.keyCode is 13
    #channel speakへ、event.target.valueを引数に
    App.room.speak event.target.value
    # inputの中身を空に
    event.target.value = ''
    alert()
    event.preventDefault()
