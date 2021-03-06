module.exports =
  generic:
    cancel: "Mégse"
    rules: "Szabályok"
  topbar:
    lobby: "Előszoba"
    openGames: 'Nyitott játékok'
    myGames: 'Játékaim'
  lobby:
    onlineUsers: 'Online játékosok'
    welcome: 'Jó szórakozást!'
  chat:
    placeholder: 'Mondd!'
    send: 'Küldés'
  gamelist:
    new: 'Új játék'
    join: 'Szállj be!'
    open: 'Megnyitás'
    players: 'Játékosok'
    createdBy: 'Tulajdonos'
    createdAt: 'Létrehozva'
    newmodal:
      go: 'Mehet!'
      ludo:
        header: 'Új játék: Ki nevet a végén?'
        takeOnStartingField: 'Le lehet ütni a saját kezdőmezőjén álló bábut'
        startOnOneAndSix: 'Nem csak 6-os, hanem 1-es kockadobás után is lehet új bábut indítani'
        reRollAfterSix: '6-os kockadobás után újra ugyanaz a játékos jön'
        skipAfterRollingThreeSixes: 'Három 6-os kockadobás után a játékos kimarad egy körből'
  ludo:
    dice: 'Dobókocka:'
    roll: 'Dobj!'
    skip: 'Kimaradok a körből'
    noPlayer: 'Senki'
    start: 'Kezdjük!'
    state:
      label: 'Állapot: '
      waitingForPlayers: 'Várjuk, hogy beszálljanak még páran...'
      diceRoll: 'Kockadobás'
      move: 'Lépés'
      skip: 'Kimarad'
    error:
      not_current_player: 'Nem te jössz!'
      wrong_state: 'Biztos, hogy nem.'
      move_not_current_players_piece: 'Ez nem a te bábud.'
    rules:
      takeOnStartingField:
        on: 'Le lehet ütni a saját kezdőmezőjén álló bábut'
        off: 'Nem lehet leütni a saját kezdőmezőjén álló bábut'
      startOnOneAndSix:
        on: '1-es és 6-os kockadobás után is lehet új bábut indítani'
        off: 'Csak 6-os kockadobás után lehet új bábut indítani'
      reRollAfterSix:
        on: '6-os kockadobás után újra ugyanaz a játékos jön'
        off: 'Nincs újradobás 6-os kockadobás után'
      skipAfterRollingThreeSixes:
        on: 'Három 6-os kockadobás után a játékos kimarad egy körből'
        off: 'Nem marad ki, aki egymás után háromszor 6-ost dob'
