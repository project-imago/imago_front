# Bindings to matrix-js-sdk

## Client object methods

### Done

### To do

### Rest

```
new MatrixClient(opts)
_createMessagesRequest(roomId, fromToken, limit, dir, timelineFilter) → {Promise}
_requestTokenFromEndpoint(endpoint, params) → {Promise}
_sendCompleteEvent(roomId, eventObject, txnId, callback) → {Promise|module:http-api.MatrixError}
_storeClientOptions(opts) → {Promise}
_unstable_setStatusMessage(newMessage) → {Promise|module:http-api.MatrixError}
addListener(event, listener) → {EventEmitter}
backPaginateRoomEventsSearch(searchResults) → {Promise|Error}
ban(roomId, userId, reason, callback) → {Promise|module:http-api.MatrixError}
beginKeyVerification(method, userId, deviceId) → {module:crypto/verification/Base}
cancelAndResendEventRoomKeyRequest(event) → {Promise}
cancelPendingEvent(event)
checkEventSenderTrust(event) → {DeviceTrustLevel}
checkKeyBackup() → {Object}
clearStores() → {Promise}
createFilter(content) → {Filter|module:http-api.MatrixError}
createKeyBackupVersion(info) → {Promise.<object>}
deactivateSynapseUser(userId) → {object}
deleteRoomTag(roomId, tagName, callback) → {Promise|module:http-api.MatrixError}
disableKeyBackup()
doesServerAcceptIdentityAccessToken() → {Promise.<boolean>}
doesServerRequireIdServerParam() → {Promise.<boolean>}
doesServerSupportLazyLoading() → {Promise.<boolean>}
doesServerSupportSeparateAddAndBind() → {Promise.<boolean>}
doesServerSupportUnstableFeature(feature) → {Promise.<boolean>}
downloadKeys(userIds, forceDownload) → {Promise}
dropFromPresenceList(callback, userIds) → {Promise|module:http-api.MatrixError}
emit(event, listener) → {boolean}
enableKeyBackup(info)
exportRoomKeys() → {Promise}
findVerificationRequestDMInProgress(roomId) → (nullable) {module:crypto/verification/request/VerificationRequest}
flagAllGroupSessionsForBackup() → {Promise.<int>}
forceDiscardSession(roomId)
forget(roomId, deleteRoom, callback) → {Promise|module:http-api.MatrixError}
generateClientSecret() → {string}
getAccountData(eventType) → (nullable) {object}
getAccountDataFromServer(eventType) → {Promise|module:http-api.MatrixError}
getCanResetTimelineCallback() → (nullable) {function}
getCapabilities(fresh) → {Promise|module:http-api.MatrixError}
getCrossSigningCacheCallbacks() → {object}
getDeviceCurve25519Key() → (nullable) {string}
getDeviceEd25519Key() → (nullable) {string}
getDeviceId() → (nullable) {string}
getDomain() → (nullable) {string}
getEventMapper() → {function}
getEventSenderDeviceInfo(event) → {Promise.<?module:crypto/deviceinfo>}
getEventTimeline(timelineSet, eventId) → {Promise}
getFilter(userId, filterId, allowCached) → {Promise|module:http-api.MatrixError}
getGlobalBlacklistUnverifiedDevices() → {boolean}
getGlobalErrorOnUnknownDevices() → {boolean}
getGroup(groupId) → {Group}
getGroups() → {Array.<Group>}
getIgnoredUsers() → {Array.<string>}
getKeyBackupEnabled() → {bool}
getKeyBackupVersion() → {Promise}
getMediaConfig(callback) → {Promise}
getNotifTimelineSet() → {EventTimelineSet}
getOpenIdToken() → {Promise|module:http-api.MatrixError}
getOrCreateFilter(filterName, filter) → {Promise.<String>}
getPresenceList(callback) → {Promise|module:http-api.MatrixError}
getPushActionsForEvent(event) → {module:pushprocessor~PushAction}
getRoom(roomId) → {Room}
getRoomPushRule(scope, roomId) → {object}
getRooms() → {Array.<Room>}
getRoomTags(roomId, callback) → {Promise|module:http-api.MatrixError}
getRoomUpgradeHistory(roomId, verifyLinks) → {Array.<Room>}
getScheduler() → (nullable) {module:scheduler~MatrixScheduler}
getStoredDevice(userId, deviceId) → {Promise.<?module:crypto/deviceinfo>}
getStoredDevicesForUser(userId) → {Promise.<Array.<module:crypto/deviceinfo>>}
getSyncState() → (nullable) {string}
getSyncStateData() → (nullable) {Object}
getTurnServers() → {Array.<Object>}
getUrlPreview(url, ts, callback) → {Promise|module:http-api.MatrixError}
getUser(userId) → (nullable) {User}
getUserId() → (nullable) {string}
getUserIdLocalpart() → (nullable) {string}
getUsers() → {Array.<User>}
getVersions() → {Promise.<object>}
getVisibleRooms() → {Array.<Room>}
hasLazyLoadMembersEnabled() → {boolean}
importRoomKeys(keys) → {Promise}
initCrypto()
invite(roomId, userId, callback) → {Promise|module:http-api.MatrixError}
inviteByEmail(roomId, email, callback) → {Promise|module:http-api.MatrixError}
inviteByThreePid(roomId, medium, address, callback) → {Promise|module:http-api.MatrixError}
inviteToPresenceList(callback, userIds) → {Promise|module:http-api.MatrixError}
isCryptoEnabled() → {boolean}
isEventSenderVerified(event) → {boolean}
isFallbackICEServerAllowed() → {boolean}
isGuest() → {boolean}
isInitialSyncComplete() → {boolean}
isKeyBackupKeyStored() → {Promise.<?object>}
isKeyBackupTrusted(info) → {object}
isRoomEncrypted(roomId) → {bool}
isSynapseAdministrator() → {boolean}
isUserIgnored(userId) → {boolean}
isVersionSupported(version) → {Promise.<bool>}
joinRoom(roomIdOrAlias, opts, callback) → {Promise|module:http-api.MatrixError}
keyBackupKeyFromPassword(password, backupInfo) → {Promise.<Buffer>}
keyBackupKeyFromRecoveryKey(recoveryKey) → {Buffer}
kick(roomId, userId, reason, callback) → {Promise|module:http-api.MatrixError}
leave(roomId, callback) → {Promise|module:http-api.MatrixError}
leaveRoomChain(roomId, includeFuture) → {Promise}
mxcUrlToHttp(mxcUrl, width, height, resizeMethod, allowDirectLinks) → (nullable) {string}
on(event, listener) → {EventEmitter}
once(event, listener) → {EventEmitter}
paginateEventTimeline(eventTimeline, optsopt) → {Promise}
peekInRoom(roomId) → {Promise|module:http-api.MatrixError}
prepareKeyBackupVersion(password) → {Promise.<object>}
redactEvent(roomId, eventId, txnIdopt, callback) → {Promise|module:http-api.MatrixError}
relations(roomId, eventId, relationType, eventType, opts) → {Object}
removeAllListeners(event) → {EventEmitter}
removeListener(event, listener) → {EventEmitter}
requestAdd3pidEmailToken(email, clientSecret, sendAttempt, nextLink) → {Promise}
requestAdd3pidMsisdnToken(phoneCountry, phoneNumber, clientSecret, sendAttempt, nextLink) → {Promise}
requestPasswordEmailToken(email, clientSecret, sendAttempt, nextLink, callback) → {Promise}
requestPasswordMsisdnToken(phoneCountry, phoneNumber, clientSecret, sendAttempt, nextLink) → {Promise}
requestRegisterEmailToken(email, clientSecret, sendAttempt, nextLink) → {Promise}
requestRegisterMsisdnToken(phoneCountry, phoneNumber, clientSecret, sendAttempt, nextLink) → {Promise}
requestVerification(userId, devices) → {Promise.<module:crypto/verification/request/VerificationRequest>}
requestVerificationDM(userId, roomId) → {Promise.<module:crypto/verification/request/VerificationRequest>}
resendEvent(event, room) → {Promise|module:http-api.MatrixError}
resetNotifTimelineSet()
restoreKeyBackupWithCache(targetRoomIdopt, targetSessionIdopt, backupInfo, opts) → {Promise.<object>}
restoreKeyBackupWithPassword(password, targetRoomIdopt, targetSessionIdopt, backupInfo, opts) → {Promise.<object>}
restoreKeyBackupWithRecoveryKey(recoveryKey, targetRoomIdopt, targetSessionIdopt, backupInfo, opts) → {Promise.<object>}
restoreKeyBackupWithSecretStorage(backupInfo, targetRoomIdopt, targetSessionIdopt, opts) → {Promise.<object>}
retryImmediately() → {boolean}
scheduleAllGroupSessionsForBackup()
scrollback(room, limit, callback) → {Promise|module:http-api.MatrixError}
searchMessageText(opts, callback) → {Promise|module:http-api.MatrixError}
searchRoomEvents(opts) → {Promise|module:http-api.MatrixError}
sendEmoteMessage(roomId, body, txnId, callback) → {Promise|module:http-api.MatrixError}
sendEvent(roomId, eventType, content, txnId, callback) → {Promise|module:http-api.MatrixError}
sendHtmlEmote(roomId, body, htmlBody, callback) → {Promise|module:http-api.MatrixError}
sendHtmlMessage(roomId, body, htmlBody, callback) → {Promise|module:http-api.MatrixError}
sendHtmlNotice(roomId, body, htmlBody, callback) → {Promise|module:http-api.MatrixError}
sendImageMessage(roomId, url, info, text, callback) → {Promise|module:http-api.MatrixError}
sendKeyBackup(roomId, sessionId, version, data) → {Promise}
sendMessage(roomId, content, txnId, callback) → {Promise|module:http-api.MatrixError}
sendNotice(roomId, body, txnId, callback) → {Promise|module:http-api.MatrixError}
sendReadReceipt(event, opts, callback) → {Promise|module:http-api.MatrixError}
sendReceipt(event, receiptType, opts, callback) → {Promise|module:http-api.MatrixError}
sendStickerMessage(roomId, url, info, text, callback) → {Promise|module:http-api.MatrixError}
sendTextMessage(roomId, body, txnId, callback) → {Promise|module:http-api.MatrixError}
sendTyping(roomId, isTyping, timeoutMs, callback) → {Promise|module:http-api.MatrixError}
setAccountData(eventType, contents, callback) → {Promise|module:http-api.MatrixError}
setAvatarUrl(url, callback) → {Promise|module:http-api.MatrixError}
setCanResetTimelineCallback(cb)
setDeviceBlocked(userId, deviceId, blockedopt) → {Promise}
setDeviceKnown(userId, deviceId, knownopt) → {Promise}
setDeviceVerified(userId, deviceId, verifiedopt) → {Promise}
setDisplayName(name, callback) → {Promise|module:http-api.MatrixError}
setFallbackICEServerAllowed(allow)
setForceTURN(forceTURN)
setGlobalBlacklistUnverifiedDevices(value)
setGlobalErrorOnUnknownDevices(value)
setGuest(isGuest)
setGuestAccess(roomId, opts) → {Promise|module:http-api.MatrixError}
setIgnoredUsers(userIds, callbackopt) → {Promise|module:http-api.MatrixError}
setMaxListeners(n) → {EventEmitter}
setNotifTimelineSet(notifTimelineSet)
setPowerLevel(roomId, userId, powerLevel, event, callback) → {Promise|module:http-api.MatrixError}
setPresence(opts, callback) → {Promise|module:http-api.MatrixError}
setProfileInfo(info, data, callback) → {Promise|module:http-api.MatrixError}
setRoomAccountData(roomId, eventType, content, callback) → {Promise|module:http-api.MatrixError}
setRoomEncryption(roomId, config) → {Promise}
setRoomMutePushRule(scope, roomId, mute) → {Promise|module:http-api.MatrixError}
setRoomName(roomId, name, callback) → {Promise|module:http-api.MatrixError}
setRoomReadMarkers(roomId, rmEventId, rrEvent, opts) → {Promise}
setRoomTag(roomId, tagName, metadata, callback) → {Promise|module:http-api.MatrixError}
setRoomTopic(roomId, topic, callback) → {Promise|module:http-api.MatrixError}
startClient(optsopt)
stopClient()
stopPeeking()
supportsVoip() → {boolean}
syncLeftRooms() → {Promise|module:http-api.MatrixError}
turnServer(callback) → {Promise|module:http-api.MatrixError}
unban(roomId, userId, callback) → {Promise|module:http-api.MatrixError}
uploadKeys() → {object}
whoisSynapseUser(userId) → {object}
```

## Client object methods from MatrixBaseApis

### Done

### To do

### Rest

```
acceptGroupInvite(groupId, opts) → {Promise|module:http-api.MatrixError}
addPushRule(scope, kind, ruleId, body, callback) → {Promise|module:http-api.MatrixError}
addRoomToGroup(groupId, roomId, isPublic) → {Promise|module:http-api.MatrixError}
addRoomToGroupSummary(groupId, roomId, categoryId) → {Promise|module:http-api.MatrixError}
addThreePid(creds, bind, callback) → {Promise|module:http-api.MatrixError}
addThreePidOnly(data) → {Promise|module:http-api.MatrixError}
addUserToGroupSummary(groupId, userId, roleId) → {Promise|module:http-api.MatrixError}
bindThreePid(data) → {Promise|module:http-api.MatrixError}
bulkLookupThreePids(query, identityAccessToken) → {Promise|module:http-api.MatrixError}
cancelUpload(promise) → {boolean}
claimOneTimeKeys(devices, key_algorithmopt, timeoutopt) → {Promise}
createAlias(alias, roomId, callback) → {Promise|module:http-api.MatrixError}
createGroup(content) → {Promise|module:http-api.MatrixError}
createRoom(options, callback) → {Promise|module:http-api.MatrixError}
deactivateAccount(auth, erase) → {Promise}
deleteAlias(alias, callback) → {Promise|module:http-api.MatrixError}
deleteDevice(device_id, auth) → {Promise|module:http-api.MatrixError}
deleteMultipleDevices(devices, auth) → {Promise|module:http-api.MatrixError}
deletePushRule(scope, kind, ruleId, callback) → {Promise|module:http-api.MatrixError}
deleteThreePid(medium, address) → {Promise|module:http-api.MatrixError}
downloadKeysForUsers(userIds, optsopt) → {Promise}
fetchRelations(roomId, eventId, relationType, eventType, opts) → {Object}
fetchRoomEvent(roomId, eventId, callback) → {Promise|module:http-api.MatrixError}
getAccessToken() → (nullable) {String}
getCasLoginUrl(redirectUrl) → {string}
getCurrentUploads() → {array}
getDevices() → {Promise|module:http-api.MatrixError}
getFallbackAuthUrl(loginType, authSessionId) → {string}
getGroupInvitedUsers(groupId) → {Promise|module:http-api.MatrixError}
getGroupProfile(groupId) → {Promise|module:http-api.MatrixError}
getGroupRooms(groupId) → {Promise|module:http-api.MatrixError}
getGroupSummary(groupId) → {Promise|module:http-api.MatrixError}
getGroupUsers(groupId) → {Promise|module:http-api.MatrixError}
getHomeserverUrl() → {string}
getIdentityAccount(identityAccessToken) → {Promise|module:http-api.MatrixError}
getIdentityHashDetails(identityAccessToken) → {Promise.<object>}
getIdentityServerUrl(stripProto) → {string}
getJoinedGroups() → {Promise|module:http-api.MatrixError}
getJoinedRoomMembers(roomId) → {Promise|module:http-api.MatrixError}
getJoinedRooms() → {Promise|module:http-api.MatrixError}
getKeyChanges(oldToken, newToken) → {Promise}
getProfileInfo(userId, info, callback) → {Promise|module:http-api.MatrixError}
getPublicisedGroups(userIds) → {Promise|module:http-api.MatrixError}
getPushers(callback) → {Promise|module:http-api.MatrixError}
getPushRules(callback) → {Promise|module:http-api.MatrixError}
getRoomDirectoryVisibility(roomId, callback) → {Promise|module:http-api.MatrixError}
getRoomIdForAlias(alias, callback) → {Promise|module:http-api.MatrixError}
getSsoLoginUrl(redirectUrl, loginType) → {string}
getStateEvent(roomId, eventType, stateKey, callback) → {Promise|module:http-api.MatrixError}
getThirdpartyLocation(protocol, params) → {Promise}
getThirdpartyProtocols() → {Promise}
getThirdpartyUser(protocol, params) → {Promise}
getThreePids(callback) → {Promise|module:http-api.MatrixError}
identityHashedLookup(addressPairs, identityAccessToken) → {Promise.<Array.<{address, mxid}>>}
inviteUserToGroup(groupId, userId) → {Promise|module:http-api.MatrixError}
isLoggedIn() → {boolean}
isUsernameAvailable(username) → {Promise}
joinGroup(groupId) → {Promise|module:http-api.MatrixError}
leaveGroup(groupId) → {Promise|module:http-api.MatrixError}
login(loginType, data, callback) → {Promise|module:http-api.MatrixError}
loginFlows(callback) → {Promise|module:http-api.MatrixError}
loginWithPassword(user, password, callback) → {Promise|module:http-api.MatrixError}
loginWithSAML2(relayState, callback) → {Promise|module:http-api.MatrixError}
loginWithToken(token, callback) → {Promise|module:http-api.MatrixError}
logout(callback) → {Promise}
lookupThreePid(medium, address, callback, identityAccessToken) → {Promise|module:http-api.MatrixError}
makeTxnId() → {string}
members(roomId, includeMembership, excludeMembership, atEventId, callback) → {Promise|module:http-api.MatrixError}
publicRooms(options, callback) → {Promise|module:http-api.MatrixError}
register(username, password, sessionId, auth, bindThreepids, guestAccessToken, inhibitLogin, callback) → {Promise|module:http-api.MatrixError}
registerGuest(optsopt, callback) → {Promise|module:http-api.MatrixError}
registerRequest(data, kindopt, callbackopt) → {Promise|module:http-api.MatrixError}
registerWithIdentityServer(hsOpenIdToken) → {Promise|module:http-api.MatrixError}
removeRoomFromGroup(groupId, roomId) → {Promise|module:http-api.MatrixError}
removeRoomFromGroupSummary(groupId, roomId) → {Promise|module:http-api.MatrixError}
removeUserFromGroup(groupId, userId) → {Promise|module:http-api.MatrixError}
removeUserFromGroupSummary(groupId, userId) → {Promise|module:http-api.MatrixError}
reportEvent(roomId, eventId, score, reason) → {Promise}
requestEmailToken(email, clientSecret, sendAttempt, nextLink, callback, identityAccessToken) → {Promise|module:http-api.MatrixError}
requestMsisdnToken(phoneCountry, phoneNumber, clientSecret, sendAttempt, nextLink, callback, identityAccessToken) → {Promise|module:http-api.MatrixError}
resolveRoomAlias(roomAlias, callback) → {Promise|module:http-api.MatrixError}
roomInitialSync(roomId, limit, callback) → {Promise|module:http-api.MatrixError}
roomState(roomId, callback) → {Promise|module:http-api.MatrixError}
search(opts, callback) → {Promise|module:http-api.MatrixError}
searchUserDirectory(opts) → {Promise}
sendStateEvent(roomId, eventType, content, stateKey, callback) → {Promise|module:http-api.MatrixError}
sendToDevice(eventType, contentMap, txnIdopt) → {Promise}
setDeviceDetails(device_id, body) → {Promise|module:http-api.MatrixError}
setGroupJoinPolicy(groupId, policy) → {Promise|module:http-api.MatrixError}
setGroupProfile(groupId, profile) → {Promise|module:http-api.MatrixError}
setGroupPublicity(groupId, isPublic) → {Promise|module:http-api.MatrixError}
setIdentityServerUrl(url)
setPassword(authDict, newPassword, callback) → {Promise|module:http-api.MatrixError}
setPusher(pusher, callback) → {Promise|module:http-api.MatrixError}
setPushRuleActions(scope, kind, ruleId, actions, callback) → {Promise|module:http-api.MatrixError}
setPushRuleEnabled(scope, kind, ruleId, enabled, callback) → {Promise|module:http-api.MatrixError}
setRoomDirectoryVisibility(roomId, visibility, callback) → {Promise|module:http-api.MatrixError}
setRoomDirectoryVisibilityAppService(networkId, roomId, visibility, callback) → {Promise|module:http-api.MatrixError}
setRoomReadMarkersHttpRequest(roomId, rmEventId, rrEventId, opts) → {Promise}
submitMsisdnToken(sid, clientSecret, msisdnToken, identityAccessToken) → {Promise|module:http-api.MatrixError}
submitMsisdnTokenOtherUrl(url, sid, clientSecret, msisdnToken) → {Promise|module:http-api.MatrixError}
unbindThreePid(medium, address) → {Promise|module:http-api.MatrixError}
unstableGetLocalAliases(roomId, callback) → {Promise|module:http-api.MatrixError}
updateGroupRoomVisibility(groupId, roomId, isPublic) → {Promise|module:http-api.MatrixError}
upgradeRoom(roomId, newVersion) → {Promise|module:http-api.MatrixError}
uploadContent(file, opts) → {Promise}
uploadKeysRequest(content, optsopt, callbackopt) → {Promise}
```

## RoomState object methods

### Done

### To do

### Rest

```
_getOrCreateMember(userId, event) → {RoomMember}
_hasSufficientPowerLevelFor(action, powerLevel) → {boolean}
_maySendEventOfType(eventType, userId, state) → {boolean}
_setOutOfBandMember(stateEvent)
_updateModifiedTime()
clearOutOfBandMembers()
clone() → {RoomState}
getInvitedMemberCount() → {integer}
getInviteForThreePidToken(token) → (nullable) {MatrixEvent}
getJoinedMemberCount() → {integer}
getLastModifiedTime() → {number}
getMember(userId) → {RoomMember}
getMembers() → {Array.<RoomMember>}
getMembersExcept(excludedIds) → {Array.<RoomMember>}
getSentinelMember(userId) → {RoomMember}
getStateEvents(eventType, stateKey) → {Array.<MatrixEvent>|MatrixEvent}
getUserIdsWithDisplayName(displayName) → {Array.<string>}
markOutOfBandMembersFailed()
markOutOfBandMembersStarted()
mayClientSendStateEvent(stateEventType, cli) → {boolean}
maySendEvent(eventType, userId) → {boolean}
maySendMessage(userId) → {boolean}
maySendRedactionForEvent(mxEvent, userId) → {boolean}
maySendStateEvent(stateEventType, userId) → {boolean}
mayTriggerNotifOfType(notifLevelKey, userId) → {boolean}
needsOutOfBandMembers() → {bool}
setInvitedMemberCount(count)
setJoinedMemberCount(count)
setOutOfBandMembers(stateEvents)
setStateEvents(stateEvents)
setTypingEvent(event)
setUnknownStateEvents(events)
```

## User object methods

### Done

### To do

### Rest

```
_unstable_updateStatusMessage(event)
_updateModifiedTime()
getLastActiveTs() → {number}
getLastModifiedTime() → {number}
setAvatarUrl(url)
setDisplayName(name)
setPresenceEvent(event)
setRawDisplayName(name)
```

## EventTimeline object methods

### Done

### To do

### Rest

```
BACKWARDS
FORWARDS
setEventMetadata(event, stateContext, toStartOfTimeline)
addEvent(event, atStart)
fork(direction) → {EventTimeline}
forkLive(direction) → {EventTimeline}
getBaseIndex() → {number}
getEvents() → {Array.<MatrixEvent>}
getFilter() → {Filter}
getNeighbouringTimeline(direction) → (nullable) {EventTimeline}
getPaginationToken(direction) → (nullable) {string}
getRoomId() → {string}
getState(direction) → {RoomState}
getTimelineSet() → {EventTimelineSet}
initialiseState(stateEvents)
removeEvent(eventId) → (nullable) {MatrixEvent}
setNeighbouringTimeline(neighbour, direction)
setPaginationToken(tokennullable, direction)
toString() → {string}
```
