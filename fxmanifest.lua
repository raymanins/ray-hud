fx_version 'cerulean'
game 'gta5'

author 'raymans'
description 'HUD for QBCore/Qbox Framework'
version '1.0.0'

ui_page 'ui.html'

files {
    'ui.html',
    'styles.css',
    'script.js'
}

client_scripts {
    'main.lua'
    'minimap.lua'
}

dependencies {
    'qb-core'
}
