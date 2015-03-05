//
//  MultiplayerStates.swift
//  Speedy
//
//  Created by John Chou on 2/28/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import Foundation

enum States {
    case START
    case CONNECTING
    case CONNECTED
    // resolving if client or server
    case CS_RESOLUTION
    case IN_GAME_STATE
}
