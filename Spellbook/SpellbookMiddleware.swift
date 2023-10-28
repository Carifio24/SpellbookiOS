//
//  SpellbookMiddlewae.swift
//  Spellbook
//
//  Created by Mac Pro on 2/26/23.
//  Copyright © 2023 Jonathan Carifio. All rights reserved.
//

import Foundation
import ReSwift

typealias AppMiddleware = Middleware<SpellbookAppState>

// TODO: See if there's a reliable way to do this dynamically
// Would need to be sure to happen BEFORE the store is created

// let appMiddlewares: [AppMiddleware] = []
//func registerAppMiddleware(middleware: AppMiddleware) -> AppMiddleware {
//    appMiddlewares.append(middleware)
//    return middleware
//}

let switchProfileMiddleware: AppMiddleware = {
    dispatch, getState in
    return { next in
        return { action in
            guard let switchAction = action as? SwitchProfileAction else {
                next(action)
                return
            }
            guard let state = getState() else { return }
            let newProfile = switchAction.newProfile
            SerializationUtils.saveCharacterProfile(profile: newProfile)
            Toast.makeToast("Character selected: " + newProfile.name)
            next(action)
        }
    }
}

let switchProfileByNameMiddleware: AppMiddleware = {
    dispatch, getState in
    return { next in
        return { action in
            guard let switchAction = action as? SwitchProfileByNameAction else {
                next(action)
                return
            }
            if let profile = try? SerializationUtils.loadCharacterProfile(name: switchAction.name) {
                do {
                    dispatch(SwitchProfileAction(newProfile: profile))
                }
            } else {
                Toast.makeToast("Error loading character profile: " + switchAction.name)
            }
        }
    }
}

let createProfileMiddleware: AppMiddleware = {
    dispatch, getState in
    return { next in
        return { action in
            guard let createAction = action as? CreateProfileAction else {
                next(action)
                return
            }
            
            let charNames = SerializationUtils.characterNameList()
            SerializationUtils.saveCharacterProfile(profile: createAction.profile)
            if charNames.count == 0 {
                dispatch(SwitchProfileAction(newProfile: createAction.profile))
            }
            dispatch(UpdateCharacterListAction())
        }
    }
}

let saveProfileMiddleware: AppMiddleware = { dispatch, getState in
    return { next in
        return { action in
            guard let saveAction = action as? SaveProfileAction else {
                next(action)
                return
            }
            SerializationUtils.saveCharacterProfile(profile: saveAction.profile)
        }
    }
}

let saveCurrentProfileMiddleware: AppMiddleware = { dispatch, getState in
    return { next in
        return { action in
            guard let saveAction = action as? SaveCurrentProfileAction else {
                next(action)
                return
            }
            guard let profile = getState()?.profile else { return }
            dispatch(SaveProfileAction(profile: profile))
        }
    }
}

let deleteProfileMiddleware: AppMiddleware = { dispatch, getState in
    return { next in
        return { action in
            guard let deleteAction = action as? DeleteProfileAction else {
                next(action)
                return
            }
            
            guard let state = getState() else { return }
            let toDelete = deleteAction.profile
            let deleted = SerializationUtils.deleteCharacterProfile(profile: toDelete)
            if (!deleted) { return }
            Toast.makeToast("Character deleted: " + toDelete.name)
            
            guard let profile = state.profile else { return }
            let deletedCurrent = (toDelete.name == profile.name)
            dispatch(UpdateCharacterListAction())
            
            let characters = SerializationUtils.characterNameList()
            if !deletedCurrent { return }
            
            if characters.count > 0 {
                do {
                    let newProfile = try SerializationUtils.loadCharacterProfile(name: characters[0])
                    dispatch(SwitchProfileAction(newProfile: newProfile))
                } catch {
                    // TODO: Is this the right thing to do here?
                    dispatch(ClearProfileAction())
                }
            } else {
                dispatch(ClearProfileAction())
            }
        }
    }
}

let deleteProfileByNameMiddleware: AppMiddleware = {
    dispatch, getState in
    return { next in
        return { action in
            guard let deleteAction = action as? DeleteProfileByNameAction else {
                next(action)
                return
            }
            if let profile = try? SerializationUtils.loadCharacterProfile(name: deleteAction.name) {
                do {
                    dispatch(DeleteProfileAction(profile: profile))
                }
            }
        }
    }
}

let makeToastMiddleware: AppMiddleware = {
    dispatch, getState in
    return { next in
        return { action in
            guard let toastAction = action as? ToastAction else {
                next(action)
                return
            }
            
            Toast.makeToast(toastAction.message)
        }
    }
}
