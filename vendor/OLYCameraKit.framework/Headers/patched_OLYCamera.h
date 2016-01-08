/**
 * @mainpage
 *
 * @~english
 *
 * @par Summary
 *
 * OLYCameraKit is a software development kit for Olympus wireless cameras.
 *
 * Using the OLYCameraKit, you can easily create applications that control the camera wirelessly.
 *
 * @par Outline
 *
 * - The following classes are available to fetch information and control a connected camera.
 *   - @ref OLYCamera
 * - The following protocols are available to receive or notify change in status of camera or wireless network.
 *   - @ref OLYCameraConnectionDelegate ... Receive state of the communication channel when it changes.
 *   - @ref OLYCameraLiveViewDelegate ... Notify state of live view image when it changes.
 *   - @ref OLYCameraPropertyDelegate ... Receive state of property values or a list of property values when it changes.
 *   - @ref OLYCameraRecordingDelegate ... Notify camera state when it changes. The camera state is regarding capturing operation which affects still image or movie.
 *   - @ref OLYCameraRecordingSupportsDelegate ... Notify camera state when it changes. The camera state is regarding capturing operation which do not affect still image or movie.
 * - The class to output error code and log is available for debugging your application.
 * - The following class is available to support a Bluetooth Smart connection
 *   - @ref OACentralConfiguration ... Receive setting information of Bluetooth Smart connection from Olympus official app, OA.Central.
 *
 * @par How to use
 *
 * Establish Wi-Fi connection between camera and mobile device in setting screen of the mobile device.
 * Connect to the camera with the SDK after checking settings for communication with the camera.
 * There is usually no need to change the communication settings.
 *
 * The camera has several run modes. Available functions are different in each mode.
 * The camera is set to standalone mode after the connection is established between camera and mobile device.
 *
 * For recording movie or photograph:
 * Connect to the camera, change to recording mode, set drive and shooting modes,
 * call start capturing and then end capturing.
 *
 * When finished using the camera, the application needs to explicitly disconnect from the camera.
 * If the application supports multitasking, please follow this procedure:
 * Application disconnects from the camera when entering background mode
 * and connects to the camera again when entering foreground mode.
 * This allows other applications to use the camera when the application does not use the camera.
 *
 * @~japanese
 *
 * @par 概要
 *
 * OLYCameraKitは、オリンパスの無線カメラ(以下カメラ)向けソフトウェア開発キット(SDK)です。
 *
 * OLYCameraKitを使えば、カメラを無線でコントロールするアプリケーションを簡単につくることができます。
 *
 * @par 構成
 *
 * - カメラと接続し、様々な操作や情報の取得を行うクラスが用意されています。
 *   - @ref OLYCamera
 * - カメラや通信ネットワークの状態が変化したことを通知するために以下のプロトコルが用意されています。
 *   - @ref OLYCameraConnectionDelegate ... カメラとの通信路に関する状態が変化した時に通知されます。
 *   - @ref OLYCameraLiveViewDelegate ... ライブビュー用画像に関する状態が変化した時に通知されます。
 *   - @ref OLYCameraPropertyDelegate ... プロパティ値またはプロパティ値リストに関する状態が変化した時に通知されます。
 *   - @ref OLYCameraRecordingDelegate ... 撮影している静止画や動画に影響する変化が生じた時に通知されます。
 *   - @ref OLYCameraRecordingSupportsDelegate ... 撮影に関するカメラなどの状態が変化した時に通知されます。
 * - アプリケーションのデバッグをサポートするために、エラーコードやログ出力のクラスが用意されています。
 * - オリンパス製アプリとの連携を支援するクラスが用意されています。
 *   - @ref OACentralConfiguration ... OA.Centralと連携してカメラとBLE接続するための設定情報を提供します。
 *
 * @par 使い方
 *
 * 最初にOLYCameraにカメラとの通信に関する設定を行ってから(通常は設定を変更する必要はありません)、SDKとしてカメラに接続しなければなりません。
 * この手続きを呼び出す前に、ユーザーもしくはアプリケーションはWi-Fi経由でスマホとカメラとの接続を確立しておく必要があります。
 *
 * カメラにはいくつかの実行モードがあり、それぞれのモードでは操作できる機能が異なります。カメラに接続した直後はスタンドアロンモードに設定されます。
 * 写真撮影または動画撮影するためには、カメラに接続してから撮影モードに移行させ撮影モードとドライブモードを設定した後で撮影開始～撮影終了を呼び出します。
 *
 * カメラの使用を終える時は、明示的にSDKとカメラの接続を切断する必要があります。
 * アプリケーションがマルチタスキングをサポートする場合は、他のアプリケーションでもカメラが使えるように、
 * バックグラウンドモードに移行する時に一時的にSDKとカメラの接続を切断し、
 * フォアグラウンドモードに移行する時に再び接続するような仕組みにしてください。
 *
 * @~
 */
/**
 *
 * @file	OLYCamera.h
 * @brief	OLYCamera class interface file.
 *
 *
 */
/*
 * Copyright (c) Olympus Imaging Corporation. All rights reserved.
 * Olympus Imaging Corp. licenses this software to you under EULA_OlympusCameraKit_ForDevelopers.pdf.
 */

#import <UIKit/UIKit.h>								// UIKit.framework
#import <Foundation/Foundation.h>					// Foundation.framework
#import <ImageIO/ImageIO.h>							// ImageIO.framework
#import <CFNetwork/CFNetwork.h>						// CFNetwork.framework
#import <CoreBluetooth/CoreBluetooth.h>             // CoreBluetooth.framework
#import <SystemConfiguration/SystemConfiguration.h> // SystemConfiguration.framework

#import "OLYCameraError.h"
#import "OLYCameraLog.h"

/**
 *
 * @defgroup types Types
 *
 * Type definition and enumerated types that are to be used by Olympus camera class
 *
 *
 * @{
 */
/** @} */

/**
 *
 * @defgroup constants Constants
 *
 * Constants referenced by Olympus camera class
 *
 *
 * @{
 */
/**
 *
 * @name Olympus camera class: camera system category
 *
 *
 * @{
 */

/**
 *
 * Version of Olympus camera kit.
 *
 * Check this value if the SDK behavior seems incorrect.
 * Problem may have been resolved in the latest version of the SDK.
 *
 *
 */
extern NSString *const OLYCameraKitVersion;

/**
 *
 * Build number of Olympus Camera Kit.
 *
 *
 */
extern NSString *const OLYCameraKitBuildNumber;

/** @} */
/** @} */

/**
 *
 *
 * Olympus camera class.
 *
 * This class provides the operation and display of live view, including content acquisition in the camera
 * and capturing of still images and recording movies by connecting to the camera.
 * This class has several categories.
 *
 * Please refer to each category for details of the interface.
 * - @ref OLYCamera(CameraConnection)
 *    - This is camera communication category of Olympus camera class.
 *      This category provides the connection and disconnection to the camera.
 * - @ref OLYCamera(CameraSystem)
 *    - This is camera system category of Olympus camera class.
 *      This category enables one to get or set the camera settings (Camera property) and change run mode.
 *    - The application can get or set the following camera properties:
 *      - Basic settings (aperture value, shutter speed, exposure mode, etc.)
 *      - Color tone and finish setting (white balance, art filter, etc.)
 *      - Focus settings (focus mode, such as focus lock)
 *      - Image quality and saving settings (image size, compression ratio, image quality mode, etc.)
 *      - Camera status (battery level, angle of view, etc.)
 *      - Recording auxiliary (face detection and sound volume level, etc.)
 *    - Please refer to the list of camera properties for more information.
 * - @ref OLYCamera(Maintenance)
 *    - This is maintenance category of Olympus camera class.
 *    - This category provides no function and is reserved for future expansion.
 * - @ref OLYCamera(Playback)
 *    - This is playback category of Olympus camera class.
 *    - This category can download and edit video and still images saved in the camera.
 * - @ref OLYCamera(PlaybackMaintenance)
 *    - This is playback auxiliary category of Olympus camera class.
 *      This category can erase video and still image and movie saved in the camera.
 * - @ref OLYCamera(Recording)
 *    - This is recording category of Olympus camera class.
 *      This category takes still pictures and records video, exposure control, and focus control.
 * - @ref OLYCamera(RecordingSupports)
 *    - This is recording auxiliary category of Olympus camera class.
 *      This category provides zoom control and live view image display.
 *
 * Several functions are provided for the vendor. These are not available in third party applications.
 *
 *
 */
@interface OLYCamera : NSObject

// See categories.

@end

// #import "OLYCamera+CameraConnection.h"
/**
 * @~english
 * @file    OLYCamera+CameraConnection.h
 * @brief   OLYCamera(CameraConnection) class interface file.
 *
 * @~japanese
 * @file    OLYCamera+CameraConnection.h
 * @brief   OLYCamera(CameraConnection) クラスインターフェースファイル
 *
 * @~
 */
/*
 * Copyright (c) Olympus Imaging Corporation. All rights reserved.
 * Olympus Imaging Corp. licenses this software to you under EULA_OlympusCameraKit_ForDevelopers.pdf.
 */

/**
 *
 * @defgroup types Types
 *
 * Type definition and enumerated types that are to be used by Olympus camera class
 *
 *
 * @{
 */
/**
 *
 * @name Olympus camera class: camera communication category
 *
 *
 * @{
 */

/**
 * Connection classification for camera.
 *
 */
enum OLYCameraConnectionType {
    /**
     * Not connected.
     *
     */
    OLYCameraConnectionTypeNotConnected,

    /**
     * Wi-Fi.
     *
     */
    OLYCameraConnectionTypeWiFi,

    /**
     * Bluetooth Smart.
     *
     */
    OLYCameraConnectionTypeBluetoothLE,

};
typedef enum OLYCameraConnectionType OLYCameraConnectionType;

/** @} */
/** @} */

@protocol OLYCameraConnectionDelegate;

#pragma mark -

/**
 *
 * This is a camera communication category of Olympus camera class.
 *
 * This category connects and disconnects the camera.
 *
 *
 * @category OLYCamera(CameraConnection)
 */
@interface OLYCamera(CameraConnection)

// This is reserved for vendors. Please do not use.
@property (strong, nonatomic) NSString *host;

// This is reserved for vendors. Please do not use.
@property (assign, nonatomic, readonly) NSInteger commandPort;

// This is reserved for vendors. Please do not use.
@property (assign, nonatomic) NSInteger liveViewStreamingPort;

// This is reserved for vendors. Please do not use.
@property (assign, nonatomic) NSInteger eventPort;

/**
 *
 * Bluetooth peripheral.
 *
 * The value is used when you connect via Bluetooth Smart to the camera.
 * Configure this value before starting connection via Bluetooth Smart.
 *
 *
 */
@property (strong, nonatomic, readwrite) CBPeripheral *bluetoothPeripheral;

/**
 *
 * Password to connect via Bluetooth Smart to the camera.
 *
 * The value may be used when you connect via Bluetooth Smart to the camera.
 * Configure this value before starting connection via Bluetooth Smart.
 *
 *
 */

@property (strong, nonatomic, readwrite) NSString *bluetoothPassword;   // __OLY_API_USER_V1__

/**
 *
 * If true, the camera starts recording setup after power on via Bluetooth Smart
 *
 * The value may be used when you connect via Bluetooth Smart to the camera.
 * Configure this value before starting connection via Bluetooth Smart.
 *
 *
 */
@property (assign, nonatomic, readwrite) BOOL bluetoothPrepareForRecordingWhenPowerOn;

/**
 *
 * Type of connection to the camera.
 *
 *
 */
@property (assign, nonatomic, readonly) OLYCameraConnectionType connectionType;

/**
 *
 * The object that acts as the delegate to receive change to communication state of the camera.
 *
 *
 */
@property (weak, nonatomic) id<OLYCameraConnectionDelegate> connectionDelegate;

/**
 *
 * Indicate whether the camera is currently connected.
 *
 *
 */
@property (assign, nonatomic, readonly) BOOL connected;

/**
 *
 * List of Bluetooth service ID.
 *
 * @return List of Bluetooth service ID.
 *
 *
 */
+ (NSArray *)bluetoothServices;

/**
 *
 * Indicate if camera requires a password for Bluetooth Smart connection.
 *
 * @param error Error details will be set when operation is abnormally terminated.
 * @return If true, password is required.
 *
 *
 */
- (BOOL)connectingRequiresBluetoothPassword:(NSError **)error;

/**
 *
 * Wake up the camera via Bluetooth Smart.
 *
 * After the camera turns on, the application can connect to the camera.
 * If the application is connected to the camera, the application will get an error.
 *
 * @param error Error details will be set when operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation had an abnormal termination.
 *
 * @see OLYCamera::bluetoothPeripheral
 * @see OLYCamera::bluetoothPassword
 * @see OLYCamera::connectingRequiresBluetoothPassword:
 * @see OLYCamera::bluetoothPrepareForRecordingWhenPowerOn
 *
 *
 */
- (BOOL)wakeup:(NSError **)error;

/**
 *
 * Connect to the camera.
 *
 * Connection to the camera is complete, the application will be able to use features of the SDK.
 * If the application wants to change the connection type when it is already connected
 * to the camera, the application must disconnect and connect again.
 *
 * @param connectionType Type of connection. You cannot specify 'not connected'.
 * @param error Error details will be set when operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation had an abnormal termination.
 *
 *
 */
- (BOOL)connect:(OLYCameraConnectionType)connectionType error:(NSError **)error;

/**
 *
 * Disconnect from the camera.
 *
 * You can also power off the camera when you disconnect from the camera.
 * If disconnect is successful, the value of the property and state of the camera will be cleared.
 * (Communication settings of the camera connection are not cleared.)
 *
 * @param powerOff If true, the camera will be powered off with disconnection from the camera.
 * @param error Error details will be set when the operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation had an abnormal termination.
 *
 *
 */
- (BOOL)disconnectWithPowerOff:(BOOL)powerOff error:(NSError **)error;

@end

#pragma mark -
#pragma mark Related Delegates

/**
 *
 * The delegate to receive change to communication state of the camera.
 *
 *
 */
@protocol OLYCameraConnectionDelegate <NSObject>
@optional

/**
 *
 * Notify that connection to the camera was lost by error.
 *
 * @param camera Instance that has lost a communication path with the camera.
 * @param error Error contents.
 *
 *
 */
- (void)camera:(OLYCamera *)camera disconnectedByError:(NSError *)error;

@end

// EOF

// #import "OLYCamera+CameraSystem.h"
/**
 *
 * @file    OLYCamera+CameraSystem.h
 * @brief   OLYCamera(CameraSystem) class interface file.
 *
 *
 */
/*
 * Copyright (c) Olympus Imaging Corporation. All rights reserved.
 * Olympus Imaging Corp. licenses this software to you under EULA_OlympusCameraKit_ForDevelopers.pdf.
 */

/**
 *
 * @defgroup types Types
 *
 * Type definition and enumerated types that are to be used by Olympus camera class
 *
 *
 * @{
 */
/**
 *
 * @name Olympus camera class: camera system category
 *
 *
 * @{
 */

/**
 *
 * Run mode of the camera.
 *
 *
 */
enum OLYCameraRunMode {
    /**
     *
     * Mode where SDK does not work.
     *
     * Run mode is sometimes set to this value when the application is not connected or mode change is abnormally terminated.
     *
     *
     */
    OLYCameraRunModeUnknown,

    /**
     *
     * Standalone mode.
     *
     * The run mode is this value immediately after connected to the camera.
     *
     * If the application changes to this mode from any other mode,
     * several camera properties return to their initial states.
     * For more information please refer to documentation of the camera list of properties.
     *
     *
     */
    OLYCameraRunModeStandalone,

    /**
     *
     * Playback mode.
     *
     * This mode is used to view the captured image in the camera.
     *
     *
     */
    OLYCameraRunModePlayback,

    /**
     *
     * Play-maintenance mode.
     *
     * This mode does not work and is reserved for future expansion.
     *
     *
     */
    OLYCameraRunModePlaymaintenance,

    /**
     *
     * Recording mode.
     *
     * This mode is used to capture still images and record videos by
     * the shutter via wireless communication.
     *
     *
     */
    OLYCameraRunModeRecording,

    /**
     *
     * Maintenance mode.
     *
     * This mode does not work and is reserved for future expansion.
     *
     *
     */
    OLYCameraRunModeMaintenance,

    // This is reserved for vendor. Please do not use.
    OLYCameraRunModePlaystream,

};
typedef enum OLYCameraRunMode OLYCameraRunMode;

/** @} */
/** @} */

/**
 *
 * @defgroup constants Constants
 *
 * Constants referenced by Olympus camera class
 *
 *
 * @{
 */
/**
 *
 * @name Olympus camera class: camera system category
 *
 *
 * @{
 */

/**
 * Dictionary key for accessing 'Camera Model Name' element of camera hardware information.
 *
 */
extern NSString *const OLYCameraHardwareInformationCameraModelNameKey;

/**
 * Dictionary key for accessing 'Camera Firmware Version' element of camera hardware information.
 */
extern NSString *const OLYCameraHardwareInformationCameraFirmwareVersionKey;

/**
 * Dictionary key for accessing 'Lens Type' element of camera hardware information.
 */
extern NSString *const OLYCameraHardwareInformationLensTypeKey;

/**
 * Dictionary key for accessing 'Lens ID' element of camera hardware information.
 */
extern NSString *const OLYCameraHardwareInformationLensIdKey;

/**
 * Dictionary key for accessing 'Lens Firmware Version' element of camera hardware information.
 */
extern NSString *const OLYCameraHardwareInformationLensFirmwareVersionKey;

/**
 * Dictionary key for accessing 'Flash ID' element of camera hardware information.
 */
extern NSString *const OLYCameraHardwareInformationFlashIdKey;

/**
 * Dictionary key for accessing 'Flash Firmware Version' element of camera hardware information.
 */
extern NSString *const OLYCameraHardwareInformationFlashFirmwareVersionKey;

/**
 * Dictionary key for accessing 'Accessory ID' element of camera hardware information.
 */
extern NSString *const OLYCameraHardwareInformationAccessoryIdKey;

/**
 * Dictionary key for accessing 'Accessory Firmware Version' element of camera hardware information.
 */
extern NSString *const OLYCameraHardwareInformationAccessoryFirmwareVersionKey;

/** @} */
/** @} */

@protocol OLYCameraPropertyDelegate;

#pragma mark -

/**
 *
 * This is a camera system category of Olympus camera class.
 *
 * This category gets or sets the camera settings (camera property) and changes the run mode.
 *
 * For example, the application can get or set the following camera properties:
 *   - Basic settings (F value, shutter speed, exposure mode, etc.)
 *   - Color tone and finish settings (white balance, art filter, etc.)
 *   - Focus settings (focus mode, such as focus lock)
 *   - Image quality and saving settings (image size, compression ratio, image quality mode, etc.)
 *   - Camera status (battery level, angle of view, etc.)
 *   - Recording auxiliary (face detection, sound volume level, etc.)
 *
 * Please refer to the camera list of properties for more information.
 *
 *
 * @category OLYCamera(CameraSystem)
 */
@interface OLYCamera(CameraSystem)

/**
 *
 * List of camera property names currently available.
 *
 * The application must check whether the target camera property is contained in the list or not.
 * If not, the target property can not be configured.
 *
 * @see OLYCamera::cameraPropertyValue:error:
 * @see OLYCamera::cameraPropertyValueList:error:
 * @see OLYCamera::setCameraPropertyValue:value:error:
 *
 *
 */
@property (strong, nonatomic, readonly) NSArray *cameraPropertyNames;

/**
 *
 * The object that acts as the delegate to receive changes to camera property.
 *
 *
 */
@property (weak, nonatomic) id<OLYCameraPropertyDelegate> cameraPropertyDelegate;

/**
 *
 * Current run mode of the camera system.
 *
 * @see OLYCamera::changeRunMode:error:
 *
 *
 */
@property (assign, nonatomic, readonly) OLYCameraRunMode runMode;

/**
 *
 * Indicate if inside of the camera is in high-temperature condition.
 *
 * You can also check using the lighting state of the LED on the camera body.
 * If the inside of the camera has reached a high temperature, please stop using the camera immediately,
 * and wait for the camera to return to normal temperature.
 *
 *
 */
@property (assign, nonatomic, readonly) BOOL highTemperatureWarning;

/**
 *
 * Indicate status of lens mount.
 *
 * Status of lens mount:
 *   - (nil) ... It is not connected to the camera, or the state is unknown.
 *   - "normal" ... The lens is mounted and available. If the lens has some additional functions,
 *     the following items are added to the end of "normal".
 *     - "+electriczoom" ... The lens is equipped with a motorized zoom.
 *     - "+macro" ... The lens is equipped with a macro mode.
 *   - "down" ... The lens is mounted. However retractable lens is not extended.
 *   - "nolens" ... Disabled because no lens is mounted.
 *   - "cantshoot" ... Disabled because of other reason.
 *
 *
 *
 */
@property (strong, nonatomic, readonly) NSString *lensMountStatus;

/**
 *
 * Indicate status of media (memory card) mount.
 *
 * Status of media mount:
 *   - (nil) ... It is not connected to the camera, or the state is unknown.
 *   - "normal" ... Available in the media already mounted.
 *   - "readonly" ... The media is already mounted. But cannot write because the media is read-only.
 *   - "cardfull" ... The media is already mounted. But cannot write because the media is no free space.
 *   - "unmount" ... Disabled because the media is not mounted.
 *   - "error" ... Disabled because of a media mount error.
 *
 *
 */
@property (strong, nonatomic, readonly) NSString *mediaMountStatus;

/**
 *
 * Indicate whether the camera is writing to the media (memory card).
 *
 * You can also check in the lighting state of the LED on the camera body.
 * While the camera is writing to the media, you will see API response is slow.
 *
 * @see OLYCamera::startTakingPicture:progressHandler:completionHandler:errorHandler:
 * @see OLYCamera::stopTakingPicture:completionHandler:errorHandler:
 * @see OLYCamera::takePicture:progressHandler:completionHandler:errorHandler:
 * @see OLYCamera::startRecordingVideo:completionHandler:errorHandler:
 * @see OLYCamera::stopRecordingVideo:errorHandler:
 *
 *
 */
@property (assign, nonatomic, readonly) BOOL mediaBusy;

/**
 *
 * Indicate whether the media (memory card) I/O error has occurred.
 *
 * There is a possibility that the media is broken.
 * Please replace with a new media if it occurs frequently.
 *
 *
 */
@property (assign, nonatomic, readonly) BOOL mediaError;

/**
 *
 * Free space of the media (memory card) attached to the camera. Unit is byte.
 *
 *
 */
@property (assign, nonatomic, readonly) NSUInteger remainingMediaCapacity;

/**
 *
 * The maximum number of images that can be stored in the media (memory card).
 *
 * The exact value depends on the data for the compression ratio of the captured image.
 * Sometimes the value does not change after capturing.
 *
 * @see OLYCamera::startTakingPicture:progressHandler:completionHandler:errorHandler:
 * @see OLYCamera::stopTakingPicture:completionHandler:errorHandler:
 * @see OLYCamera::takePicture:progressHandler:completionHandler:errorHandler:
 *
 *
 */
@property (assign, nonatomic, readonly) NSUInteger remainingImageCapacity;

/**
 *
 * The maximum number of seconds a movie that can be stored in the media (memory card).
 *
 * The exact value depends on the data for the compression ratio of the captured video.
 *
 * @see OLYCamera::startRecordingVideo:completionHandler:errorHandler:
 * @see OLYCamera::stopRecordingVideo:errorHandler:
 *
 *
 */
@property (assign, nonatomic, readonly) NSTimeInterval remainingVideoCapacity;

/**
 *
 * Get hardware information of the camera.
 *
 * @param error Error details will be set when the operation is abnormally terminated.
 * @return The hardware information of the camera.
 *
 * Hardware information is in dictionary format.
 * The following keys are defined in order to access each element.
 *   - #OLYCameraHardwareInformationCameraModelNameKey ... Camera model name.
 *   - #OLYCameraHardwareInformationCameraFirmwareVersionKey ... Camera firmware version.
 *   - #OLYCameraHardwareInformationLensTypeKey ... Lens type.
 *   - #OLYCameraHardwareInformationLensIdKey ... Lens ID.
 *   - #OLYCameraHardwareInformationLensFirmwareVersionKey ... Lens firmware version.
 *   - #OLYCameraHardwareInformationFlashIdKey ... Flash ID.
 *   - #OLYCameraHardwareInformationFlashFirmwareVersionKey ... Flash firmware version.
 *   - #OLYCameraHardwareInformationAccessoryIdKey ... Accessory ID.
 *   - #OLYCameraHardwareInformationAccessoryFirmwareVersionKey ... Accessory firmware version.
 *
 * Please refer to the related documentation for more information.
 *
 *
 */
- (NSDictionary *)inquireHardwareInformation:(NSError **)error;

/**
 *
 * Get title of the camera property.
 *
 * If the application specifies a value that does not exist in the list of camera properties currently available,
 * the application will have an error.
 * Please refer to the documentation of the camera list of properties for more information.
 *
 * @param name The camera property name. (e.g. "APERTURE", "SHUTTER", "ISO", "WB")
 * @return Display name for camera property. (e.g. "Aperture", "Shutter Speed", "ISO Sensitivity", "White Balance")
 *
 * @see OLYCamera::cameraPropertyNames
 *
 *
 */
- (NSString *)cameraPropertyTitle:(NSString *)name;

/**
 *
 * Get list of the camera property values that can be set.
 *
 * If the application specifies a value that does not exist in the list of camera properties currently available,
 * the application will have an error.
 * If the application changes settings such as shooting mode,
 * there are times when the contents of the list changes.
 * Please refer to the documentation of the camera list of properties for more information.
 *
 * Each value in the list is a string in the form of "<Property Name/Property Value>."
 *
 * @param name The camera property name. (e.g. "APERTURE", "SHUTTER", "ISO")
 * @param error Error details will be set when the operation is abnormally terminated.
 * @return The list of the camera property values that can be set.
 *
 *
 * @see OLYCamera::cameraPropertyNames
 * @see OLYCamera::cameraPropertyValue:error:
 *
 *
 */
- (NSArray *)cameraPropertyValueList:(NSString *)name error:(NSError **)error;

/**
 *
 * Get value that is set in the camera properties.
 *
 * If the application specifies a value that does not exist in the list of camera properties currently available,
 * the application will get an error.
 * Depending on shooting mode, connection type, etc.,
 * several properties are read-only access or prohibited.
 * Please refer to the documentation of the camera list of properties for more information.
 *
 * The return value is a string in the form of "<Property Name/Property Value>."
 *
 * @param name The camera property name. (e.g. "APERTURE", "SHUTTER", "ISO")
 * @param error Error details will be set when operation is abnormally terminated.
 * @return Pair of property name and property value set in the property. (e.g. "<APERTURE/3.5>", "<SHUTTER/250>", "<ISO/Auto>")
 *
 *
 * @see OLYCamera::cameraPropertyNames
 * @see OLYCamera::canSetCameraProperty:
 * @see OLYCamera::setCameraPropertyValue:value:error:
 *
 *
 */
- (NSString *)cameraPropertyValue:(NSString *)name error:(NSError **)error;

/**
 *
 * Get values that are set in the camera properties.
 *
 * If the application specifies a value that does not exist in the list of camera properties currently available,
 * the application will get an error.
 * Depending on shooting mode, connection type, etc.,
 * several properties are read-only access or prohibited.
 * Please refer to the documentation of the camera list of properties for more information.
 *
 * @param names The camera property names. Each element is a string.
 * @param error Error details will be set when operation is abnormally terminated.
 * @return The values set in the camera properties.
 *
 * The retrieved values are in dictionary format.
 * The dictionary key is the camera property name.
 * Setting of the camera property is stored in value corresponding to the key.
 *
 * @see OLYCamera::cameraPropertyNames
 * @see OLYCamera::setCameraPropertyValues:error:
 *
 *
 */
- (NSDictionary *)cameraPropertyValues:(NSSet *)names error:(NSError **)error;

/**
 *
 * Get title of the camera property value.
 *
 * If the application specifies a value that does not exist in the list of camera properties currently available,
 * the application will get an error.
 * Depending on the setting value of the shooting mode, connection type, etc.,
 * several properties are read-only access or prohibited.
 * Please refer to the documentation of the camera list of properties for more information.
 *
 * The argument for parameter "value" is a string in the form of "<Property Name/Property Value>."
 *
 * @param value Pair of property name and property value set in the property. (e.g. "<APERTURE/3.5>", "<SHUTTER/250>", "<ISO/Auto>", "<WB/WB_AUTO>")
 * @return Display name for camera property value. (e.g. "3.5", "250", "Auto", "WB Auto")
 *
 * @see OLYCamera::cameraPropertyNames
 * @see OLYCamera::cameraPropertyValue:error:
 *
 *
 */
- (NSString *)cameraPropertyValueTitle:(NSString *)value;

/**
 *
 * Check to see if value to the camera properties can be set.
 *
 * If the application specifies a value that does not exist in the list of camera properties currently available,
 * the application will get an error.
 * Depending on the setting value of the shooting mode, connection type, etc.,
 * several properties are read-only access or prohibited.
 * Please refer to the documentation of the camera list of properties for more information.
 *
 * @param name The camera property name. (e.g. "APERTURE", "SHUTTER", "ISO", "WB")
 * @return If true, the camera property can be set. If false, the camera property cannot be set.
 *
 * @see OLYCamera::cameraPropertyNames
 * @see OLYCamera::setCameraPropertyValue:value:error:
 *
 *
 */
- (BOOL)canSetCameraProperty:(NSString *)name;

/**
 *
 * Set value to the camera properties.
 *
 * If the application specifies a value that does not exist in the list of camera properties currently available,
 * the application will get an error.
 * Depending on the setting value of the shooting mode and connection type etc.,
 * there are several properties that are read-only access or prohibited.
 * Please refer to the documentation of the camera list of properties for more information.
 *
 * The argument for parameter "value" is a string in the form of "<Property Name/Property Value>."
 * @param name The camera property name (e.g. "APERTURE", "SHUTTER", "ISO", "WB").
 * @param value Pair of property name and property value set in the property. (e.g. "<APERTURE/3.5>", "<SHUTTER/250>", "<ISO/Auto>", "<WB/WB_AUTO>")
 * @param error Error details will be set when operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation was abnormally terminated.
 *
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *   - #OLYCameraRunModeMaintenance
 *
 * @see OLYCamera::cameraPropertyNames
 * @see OLYCamera::cameraPropertyValue:error:
 * @see OLYCamera::canSetCameraProperty:
 *
 *
 */
- (BOOL)setCameraPropertyValue:(NSString *)name value:(NSString *)value error:(NSError **)error;

/**
 *
 * Set values to camera properties.
 *
 * Specifying a value that does not exist in the list of camera properties currently available,
 * will give an error.
 * Depending on the setting value of the shooting mode, connection type, etc.,
 * several properties are read-only access or prohibited.
 * Please refer to the documentation of the camera list of properties for more information.
 *
 * @param values The pairs of the camera property value and name.
 * @param error Error details will be set when operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation was abnormally terminated.
 *
 * Name-value pairs of the camera properties that can be specified in dictionary format.
 * The application must specify the camera property name in the dictionary key
 * and store the value associated with that key in the camera properties.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *   - #OLYCameraRunModeMaintenance
 *
 * @see OLYCamera::cameraPropertyNames
 * @see OLYCamera::cameraPropertyValues:error:
 * @see OLYCamera::setCameraPropertyValue:value:error:
 *
 *
 */
- (BOOL)setCameraPropertyValues:(NSDictionary *)values error:(NSError **)error;

/**
 *
 * Change run mode of the camera.
 *
 * Available camera features change for different run modes.
 * For example, application should change the mode to #OLYCameraRunModePlayback when shooting photographs,
 * and should change the mode to #OLYCameraRunModeRecording when getting a list of the camera contents.
 * Please refer to the related documentation for more information on relationship between
 * run mode and available camera features.
 *
 * Response of this API may become slow when shooting or writing to memory card.
 *
 * @param mode Run mode of the camera.
 * @param error Error details will be set when the operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation was abnormally terminated.
 *
 * @see OLYCamera::runMode
 *
 *
 */
- (BOOL)changeRunMode:(OLYCameraRunMode)mode error:(NSError **)error;

/**
 *
 * Change date and time of camera.
 *
 * When capturing without specifying date and time in the camera,
 * a wrong value is set to metadata of media (still image and movie) and time stamp of media file.
 *
 * Date and time must be specified in Greenwich Mean Time (GMT), with time zone set in the mobile device.
 * OS standard API returns date and time in GMT format,
 * and this method can use the returned value without changing the format.
 *
 * @param date Date and time.
 * @param error Error details will be set when the operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModeStandalone
 *   - #OLYCameraRunModePlayback
 *   - #OLYCameraRunModePlaymaintenance
 *
 *
 */
- (BOOL)changeTime:(NSDate *)date error:(NSError **)error;

/**
 *
 * Register geolocation information to the camera.
 *
 * After the application registers the current geolocation in the camera,
 * the GPS geolocation information will be set in the meta-data of the picture during capture.
 *
 * The geolocation information must be specified by GGA and RMC defined in NMEA-0183.
 *
 * @param location The new geolocation information.
 * @param error Error details will be set when the operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation was abnormally terminated.
 *
 * @see OLYCamera::clearGeolocation:
 *
 *
 */
- (BOOL)setGeolocation:(NSString *)location error:(NSError **)error;

/**
 *
 * Discard registered geolocation information.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation was abnormally terminated.
 *
 * @see OLYCamera::setGeolocation:error:
 *
 *
 */
- (BOOL)clearGeolocation:(NSError **)error;

// ;-)

@end

#pragma mark -
#pragma mark Related Delegates

/**
 *
 * Delegate to receive when the camera property changes.
 *
 *
 */
@protocol OLYCameraPropertyDelegate <NSObject>
@optional

/**
 *
 * Notify that the list of camera property value or camera property value is updated.
 *
 * @param camera Instances indicating change of camera property.
 * @param name Name of the camera property that has changed.
 *
 *
 */
- (void)camera:(OLYCamera *)camera didChangeCameraProperty:(NSString *)name;

@end

// EOF

// #import "OLYCamera+Playback.h"
/**
 *
 * @file    OLYCamera+Playback.h
 * @brief   OLYCamera(Playback) class interface file.
 *
 *
 */
/*
 * Copyright (c) Olympus Imaging Corporation. All rights reserved.
 * Olympus Imaging Corp. licenses this software to you under EULA_OlympusCameraKit_ForDevelopers.pdf.
 */

/**
 *
 * @defgroup types Types
 *
 * Type definition and enumerated types that are to be used by Olympus camera class
 *
 *
 * @{
 */
/**
 *
 * @name Olympus camera class: playback category
 *
 *
 * @{
 */

/**
 *
 * Supported video quality when resized.
 *
 *
 */
enum OLYCameraResizeVideoQuality {
    /**
     *
     * High quality video.
     * File size is bigger than that of normal quality video.
     *
     *
     */
    OLYCameraResizeVideoQualityFine,

    /**
     *
     * Normal quality video.
     *
     *
     */
    OLYCameraResizeVideoQualityNormal,
};
typedef enum OLYCameraResizeVideoQuality OLYCameraResizeVideoQuality;

/**
 *
 * Supported sizes for images.
 *
 *
 */
typedef CGFloat OLYCameraImageResize;

/** @} */
/** @} */

/**
 *
 * @defgroup constants Constants
 *
 * Constants referenced by Olympus camera class
 *
 *
 * @{
 */
/**
 *
 * @name Olympus camera class: playback category
 *
 *
 * @{
 */

/**
 * Resize long side of the image to 1024 pixels.
 *
 */
extern const OLYCameraImageResize OLYCameraImageResize1024;

/**
 * Resize long side of the image to 1600 pixels.
 *
 */
extern const OLYCameraImageResize OLYCameraImageResize1600;

/**
 * Resize long side of the image to 1920 pixels.
 *
 */
extern const OLYCameraImageResize OLYCameraImageResize1920;

/**
 * Resize long side of the image to 2048 pixels.
 *
 */
extern const OLYCameraImageResize OLYCameraImageResize2048;

/**
 * Use the original size of the image.
 *
 */
extern const OLYCameraImageResize OLYCameraImageResizeNone;

/**
 * Dictionary key for accessing 'Directory path' elements of the content information.
 *
 */
extern NSString *const OLYCameraContentListDirectoryKey;

/**
 * Dictionary key for accessing 'File name' elements of content information.
 *
 */
extern NSString *const OLYCameraContentListFilenameKey;

/**
 * Dictionary key for accessing 'File size' elements of content information.
 *
 */
extern NSString *const OLYCameraContentListFilesizeKey;

/**
 * Dictionary key for accessing 'File type' elements of content information.
 *
 */
extern NSString *const OLYCameraContentListFiletypeKey;

/**
 * Dictionary key for accessing 'File attribute list' elements of content information.
 *
 */
extern NSString *const OLYCameraContentListAttributesKey;

/**
 * Dictionary key for accessing 'File modified date' elements of content information.
 *
 */
extern NSString *const OLYCameraContentListDatetimeKey;

/**
 * Dictionary key for accessing 'Extension' elements of content information.
 *
 */
extern NSString *const OLYCameraContentListExtensionKey;

/** @} */
/** @} */

@protocol OLYCameraPlaybackDelegate;

#pragma mark -

/**
 *
 * Playback category of Olympus camera class.
 *
 * This category downloads and edits still image and movie saved in the camera.
 *
 *
 * @category OLYCamera(Playback)
 */
@interface OLYCamera(Playback)

/**
 *
 * Delegate object to receive changes to playback operations.
 *
 *
 */
@property (weak, nonatomic) id<OLYCameraPlaybackDelegate> playbackDelegate;

/**
 *
 * Download list of all supported media (still image and video) in the camera.
 *
 * Download list of files in /DCIM directory of memory card that is inserted in the camera.
 * List contains all still image and movie files in supported format.
 * Application should distinguish unsupported files using file extension and eliminate them from the list before use.

 * @param handler Callback used when download is complete.
 *
 * Argument of download completion callback.
 *   - list ... List of all supported media stored in memory card in array format.
 *   - error ... Error details are set when the operation is abnormally terminated.
 *
 * Each element of the list is in dictionary format.
 * Dictionary key is defined to access the element.
 *   - #OLYCameraContentListDirectoryKey ... Directory path.
 *   - #OLYCameraContentListFilenameKey ... File name.
 *   - #OLYCameraContentListFilesizeKey ... File size.
 *   - #OLYCameraContentListFiletypeKey ... File type.
 *     The following are the file types.
 *     - "directory" ... Directory.
 *     - "file" ... File.
 *   - #OLYCameraContentListAttributesKey ... Array of file attributes. Array is normally set to empty.
 *     The following are the file attributes.
 *      - "protected" ... Protected file and cannot be deleted.
 *      - "hidden" ... Hidden file.
 *   - #OLYCameraContentListDatetimeKey ... Date object that represents date and time the file was changed.
 *   - #OLYCameraContentListExtensionKey ... Array of extended information.
 *
 * Please refer to the related documentation for more information on extended information.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 *
 */
- (void)downloadContentList:(void (^)(NSMutableArray *list, NSError *error))handler;

/**
 *
 * Download thumbnail of media (still image and movie) stored in memory card.
 *
 * File path must be string which combines the directory path and file name
 * obtained from list of all supported media. Otherwise an error occurs.
 *
 * @param path File path to the still image or movie.
 * @param progressHandler Callback used when the download progress changes.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when download is aborted.
 *
 * Argument of progressHandler
 *   - progress ... Progress rate ranges from 0.0 when starting to 1.0 when complete.
 *   - stop ... If true, download is canceled, and errorHandler is invoked.
 *
 * Argument of completionHandler
 *   - image ... Binary data of thumbnail.
 *   - metadata ... Metadata of the thumbnail.
 *     There are cases where the following information is included in addition to the EXIF information.
 *     - "gpstag" ... 1 if the content has positioning information, 0 if it does not.
 *     - "moviesec" ...  Movie length in seconds if the movie file has length information.
 *     - "detectversion" ... Reserved for vendor.
 *     - "detectid" ... Reserved for vendor.
 *     - "groupid" ... Reserved for vendor.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 *
 *
 */
- (void)downloadContentThumbnail:(NSString *)path progressHandler:(void (^)(float progress, BOOL *stop))progressHandler completionHandler:(void (^)(NSData *data, NSMutableDictionary *metadata))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;

/**
 *
 * Download reduced image of media (still image and movie) stored in memory card.
 *
 * File path must be string which combines the directory path and file name
 * obtained from list of all supported media. Otherwise an error occurs.
 *
 * @param path File path to the still image or movie.
 * @param progressHandler Callback used when the download progress changes.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when download is aborted.
 *
 * Argument of progressHandler
 *   - progress ... Progress rate ranges from 0.0 when starting to 1.0 when complete.
 *   - stop ... If true, download is canceled, and errorHandler is invoked.
 *
 * Argument of completionHandler
 *   - data ... Binary data of the reduced image.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 *
 */
- (void)downloadContentScreennail:(NSString *)path progressHandler:(void (^)(float progress, BOOL *stop))progressHandler completionHandler:(void (^)(NSData *data))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;

/**
 *
 * Download a resized still image.
 *
 * File path must be string which combines the directory path and file name
 * obtained from list of all supported media. Otherwise an error occurs.
 *
 * @param path File path to the still image.
 * @param resize Size in number of pixels after resizing.
 * @param progressHandler Callback used when the download progress changes.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when download is aborted.
 *
 * Argument of progressHandler
 *   - progress ... Progress rate ranges from 0.0 when starting to 1.0 when complete.
 *   - stop ... If true, download is canceled, and errorHandler is invoked.
 *
 * Argument of completionHandler
 *   - data ... Binary data of the image.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 *
 */
- (void)downloadImage:(NSString *)path withResize:(OLYCameraImageResize)resize progressHandler:(void (^)(float progress, BOOL *stop))progressHandler completionHandler:(void (^)(NSData *data))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;

/**
 *
 * Download media (still image and movie) stored in memory card.
 *
 * File path must be string which combines the directory path and file name
 * obtained from list of all supported media. Otherwise an error occurs.
 *
 * @param path File path to the still image or movie.
 * @param progressHandler Callback used when the download progress changes.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when download is aborted.
 *
 * Argument of progressHandler
 *   - progress ... Progress rate ranges from 0.0 when starting to 1.0 when complete.
 *   - stop ... If true, download is canceled, and errorHandler is invoked.
 *
 * Argument of completionHandler
 *   - data ... Binary data of the media.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 *
 */
- (void)downloadContent:(NSString *)path progressHandler:(void (^)(float progress, BOOL *stop))progressHandler completionHandler:(void (^)(NSData *data))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;

/**
 *
 * Split large media (still image or movie) into smaller parts and download each part.
 *
 * File path must be string which combines the directory path and file name
 * obtained from list of all supported media. Otherwise an error occurs.
 *
 * @param path File path to the still image or movie.
 * @param progressHandler Callback used when the part is downloaded.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when download is aborted.
 *
 * Argument of progressHandler
 *   - data ... Received binary data of the part.
 *   - progress ... Progress rate ranges from 0.0 when starting to 1.0 when complete.
 *   - stop ... If true, download is canceled, and errorHandler is invoked.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 *
 */
- (void)downloadLargeContent:(NSString *)path progressHandler:(void (^)(NSData *data, float progress, BOOL *stop))progressHandler completionHandler:(void (^)())completionHandler errorHandler:(void (^)(NSError *error))errorHandler;

/**
 *
 * Count the number of media (still image and movie) in the camera.
 *
 * @param error Error details are set when the operation is abnormally terminated.
 * @return Number of media.
 *
 * If the number of the acquired media is zero, an error may occur.
 * If the application wants to know the exact number of media,
 * the application should check that error details are not set.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 *
 */
- (NSInteger)countNumberOfContents:(NSError **)error;

/**
 *
 * Get information of media (still image and movie) stored in memory card.
 *
 * File path must be string which combines the directory path and file name
 * obtained from list of all supported media. Otherwise an error occurs.
 *
 * @param path File path to the still image or movie.
 * @param error Error details are set when the operation is abnormally terminated.
 * @return Information of the media.
 *
 * Information on still image
 *   - Please refer to the related documentation for detailed information.
 *   - The application can also see EXIF information that is included in metadata of the media.
 *
 * Information on movie (string format)
 *   - "playtime" ... Movie length in seconds.
 *   - "moviesize" ... Pixel size of the movie frame. The format is "[height]x[width]". For example "1920x1080"
 *   - "shootingdatetime" ... Date and time taken. Format is "[YYYYMMDD]T[hhmm]". For example "20141124T1234"
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 *
 */
- (NSDictionary *)inquireContentInformation:(NSString *)path error:(NSError **)error;

// ;-)

// ;-)

// ;-)

/**
 *
 * Resize each frame of the video, and save it as a new file in the camera's memory card.
 *
 * String that the application specifies in the file path of the content.  String must
 * combine the directory path and file name obtained from the downloaded contents list.
 * If the application specifies a non-video file, the application will get an error.
 *
 * @param path File path to the video content.
 * @param resize Frame size in number of pixels after resizing. (only 1280 is valid in current version)
 * @param quality Quality of video after resizing.
 * @param progressHandler Callback used when the resizing progress changes.
 * @param completionHandler Callback used when resizing is complete.
 * @param errorHandler Callback used when resizing is abnormally terminated.
 *
 * Argument of progress callback
 *   - progress ... Progress rate ranges from 0.0 when starting to 1.0 when complete.
 *   - stop ... If set to true, abnormal termination callback is invoked and resizing is canceled.
 *
 * Argument of abnormal termination callback
 *   - error ... Error details are set when the operation is abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run modes and otherwise causes an error.
 *   - #OLYCameraRunModePlayback
 *
 *
 */
- (void)resizeVideoFrame:(NSString *)path size:(CGFloat)resize quality:(OLYCameraResizeVideoQuality)quality progressHandler:(void (^)(float progress, BOOL *stop))progressHandler completionHandler:(void (^)())completionHandler errorHandler:(void (^)(NSError *error))errorHandler;

@end

#pragma mark -
#pragma mark Related Delegates

/**
 *
 * Delegate to receive camera state regarding playback operation when it changes.
 *
 *
 */
@protocol OLYCameraPlaybackDelegate <NSObject>
@optional

// something functions will come...

@end

// EOF

// #import "OLYCamera+PlaybackMaintenance.h"
/**
 *
 * @file    OLYCamera+PlaybackMaintenance.h
 * @brief   OLYCamera(PlaybackMaintenance) class interface file.
 *
 *
 */
/*
 * Copyright (c) Olympus Imaging Corporation. All rights reserved.
 * Olympus Imaging Corp. licenses this software to you under EULA_OlympusCameraKit_ForDevelopers.pdf.
 */

/**
 *
 * Playback auxiliary category of Olympus camera class.
 *
 * This category can erase video and still image and movie saved in the camera.
 *
 *
 * @category OLYCamera(PlaybackMaintenance)
 */
@interface OLYCamera(PlaybackMaintenance)

// ;-)

// ;-)

/**
 *
 * Protect media (still image and movie) stored in memory card.
 *
 * When the application tries to delete the protected media, an error occurs.
 * File path must be string which combines the directory path and file name
 * obtained from list of all supported media. Otherwise an error occurs.
 *
 * @param path File path of the media.
 * @param error Error details are set when the operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModePlaymaintenance
 *
 * @see OLYCamera::unprotectContent:error:
 * @see OLYCamera::unprotectAllContents:completionHandler:errorHandler:
 *
 *
 */
- (BOOL)protectContent:(NSString *)path error:(NSError **)error;

/**
 *
 * Cancel protection of the media (still image and movie) stored in memory card.
 *
 * When the protection is canceled, the application is allowed to delete the media.
 * File path must be string which combines the directory path and file name
 * obtained from list of all supported media. Otherwise an error occurs.
 *
 * @param path File path of the media.
 * @param error Error details are set when the operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModePlaymaintenance
 *
 * @see OLYCamera::protectContent:error:
 *
 *
 */
- (BOOL)unprotectContent:(NSString *)path error:(NSError **)error;

/**
 *
 * Cancel protection of all the media (still image and movie) stored in memory card.
 *
 * @param progressHandler Callback used when cancellation progress changes.
 * @param completionHandler Callback used when cancellation is complete.
 * @param errorHandler Callback used when cancellation is aborted.
 *
 * Argument of progressHandler
 *   - progress ... Progress rate ranges from 0.0 when starting to 1.0 when complete.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModePlaymaintenance
 *
 * @see OLYCamera::protectContent:error:
 *
 *
 */
- (void)unprotectAllContents:(void (^)(float progress))progressHandler completionHandler:(void (^)())completionHandler errorHandler:(void (^)(NSError *error))errorHandler;

/**
 *
 * Delete media (still image and movie) stored in memory card.
 *
 * File path must be string which combines the directory path and file name
 * obtained from list of all supported media. Otherwise an error occurs.
 * When the application tries to delete the protected media, an error occurs.
 *
 * @param path File path of the media.
 * @param error Error details are set when the operation is abnormally terminated.
 * @return If true, the operation was successful. If false, the operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModePlaymaintenance
 *
 *
 */
- (BOOL)eraseContent:(NSString *)path error:(NSError **)error;

// ;-)

// ;-)

@end

// EOF

// #import "OLYCamera+Recording.h"
/**
 * @~english
 * @file    OLYCamera+Recording.h
 * @brief   OLYCamera(Recording) class interface file.
 *
 * @~japanese
 * @file    OLYCamera+Recording.h
 * @brief   OLYCamera(Recording) クラスインターフェースファイル
 *
 * @~
 */
/*
 * Copyright (c) Olympus Imaging Corporation. All rights reserved.
 * Olympus Imaging Corp. licenses this software to you under EULA_OlympusCameraKit_ForDevelopers.pdf.
 */

/**
 *
 * @defgroup types Types
 *
 * Type definition and enumerated types that are to be used by Olympus camera class
 *
 *
 * @{
 */
/**
 *
 * @name Olympus camera class: recording category
 *
 *
 * @{
 */

/**
 *
 * Type of shooting mode and drive mode.
 *
 *
 */
enum OLYCameraActionType {

    /**
     *
     * Mode is unknown.
     *
     *
     */
    OLYCameraActionTypeUnknown,

    /**
     *
     * Still image single shooting mode.
     *
     * Mode that takes 1 image after a single tap.
     *
     *
     */
    OLYCameraActionTypeSingle,

    /**
     *
     * Still image continuous shooting mode.
     *
     * Mode that quickly takes multiple images while a user is touching the device.
     *
     *
     */
    OLYCameraActionTypeSequential,

    /**
     *
     * Movie recording mode.
     *
     * Mode that starts recording when user taps device and stops recording when user again taps device.
     *
     *
     */
    OLYCameraActionTypeMovie,

};
typedef enum OLYCameraActionType OLYCameraActionType;

/**
 *
 * Progress of the capturing operation.
 *
 *
 */
enum OLYCameraTakingProgress {
    /**
     *
     * Start auto focus.
     *
     * This notification is called even if focus is locked.
     *
     *
     */
    OLYCameraTakingProgressBeginFocusing,

    /**
     *
     * End auto focus.
     *
     * This timing is appropriate for the application to play a sound effect or
     * display the focus result.
     *
     *
     */
    OLYCameraTakingProgressEndFocusing,

    /**
     *
     * Preparation of the exposure has been completed.
     *
     *
     */
    OLYCameraTakingProgressReadyCapturing,

    /**
     *
     * Start exposure.
     *
     * This timing is appropriate for the application to play a sound effect or
     * display that the shutter is open.
     *
     *
     */
    OLYCameraTakingProgressBeginCapturing,

    /**
     *
     * This is reserved for future use.
     *
     *
     */
    OLYCameraTakingProgressBeginNoiseReduction,

    /**
     *
     * This is reserved for future use.
     *
     *
     */
    OLYCameraTakingProgressEndNoiseReduction,

    /**
     *
     * Exposure is complete.
     *
     * This timing is appropriate for the application to play a sound effect or display that the shutter is closed.
     *
     *
     */
    OLYCameraTakingProgressEndCapturing,

    /**
     *
     * Shooting action is complete.
     *
     *
     */
    OLYCameraTakingProgressFinished,
};
typedef enum OLYCameraTakingProgress OLYCameraTakingProgress;

/**
 *
 * Size of live view that the camera supports.
 *
 *
 */
typedef CGSize OLYCameraLiveViewSize;

/** @} */
/** @} */

/**
 *
 * @defgroup constants Constants
 *
 * Constants referenced by Olympus camera class
 *
 *
 * @{
 */
/**
 *
 * @name Olympus camera class: recording category
 *
 *
 * @{
 */

/**
 * Display in QVGA (320x240) size live view.
 *
 */
extern const OLYCameraLiveViewSize OLYCameraLiveViewSizeQVGA;

/**
 * Display in VGA (640x480) size live view.
 *
 */
extern const OLYCameraLiveViewSize OLYCameraLiveViewSizeVGA;

/**
 * Display in SVGA (800x600) size live view.
 *
 */
extern const OLYCameraLiveViewSize OLYCameraLiveViewSizeSVGA;

/**
 * Display in XGA (1024x768) size live view.
 *
 */
extern const OLYCameraLiveViewSize OLYCameraLiveViewSizeXGA;

/**
 * Display in Quad-VGA (1280x960) size live view.
 *
 */
extern const OLYCameraLiveViewSize OLYCameraLiveViewSizeQuadVGA;

/**
 *
 * Dictionary key to access elements that specifies maximum number of shots at beginning of continuous shooting.
 *
 */
extern NSString *const OLYCameraStartTakingPictureOptionLimitShootingsKey;

/**
 *
 * Dictionary key to access focusing result given as parameter of progressHandler when shooting.
 *
 */
extern NSString *const OLYCameraTakingPictureProgressInfoFocusResultKey;

/**
 *
 * Dictionary key to access coordinates of focus given as parameter of progressHandler when shooting.
 *
 */
extern NSString *const OLYCameraTakingPictureProgressInfoFocusRectKey;

/** @} */
/** @} */

@protocol OLYCameraLiveViewDelegate;
@protocol OLYCameraRecordingDelegate;

#pragma mark -

/**
 *
 * Recording category of Olympus camera class.
 *
 * This category takes still pictures, records video, and controls exposure and focus.
 *
 * Application can configure exposure parameters, focus, color and tone using camera property control methods in
 * @ref OLYCamera(CameraSystem) categories.
 * Please refer to list of camera properties for more information.
 *
 *
 * @category OLYCamera(Recording)
 */
@interface OLYCamera(Recording)

/**
 *
 * Indicate that live view starts automatically when run mode is changed to Recording mode.
 *
 * If false, call API to start live view after changing run mode to Recording mode.
 *
 * @see OLYCamera::startLiveView:
 * @see OLYCamera::stopLiveView:
 *
 *
 */
@property (assign, nonatomic) BOOL autoStartLiveView;

/**
 *
 * Indicate that live view started.
 *
 * @see OLYCamera::startLiveView:
 * @see OLYCamera::stopLiveView:
 *
 *
 */
@property (assign, nonatomic ,readonly) BOOL liveViewEnabled;

/**
 *
 * Frame size of live view in pixels.
 *
 * @see OLYCamera::changeLiveViewSize:error:
 *
 *
 */
@property (assign, nonatomic, readonly) OLYCameraLiveViewSize liveViewSize;

/**
 *
 * Delegate object that notifies state of live view image when it changes.
 *
 *
 */
@property (weak, nonatomic) id<OLYCameraLiveViewDelegate> liveViewDelegate;

/**
 *
 * Delegate object that notifies camera state when it changes. The camera state relates to capturing operation which affects still image or movie.
 *
 *
 */
@property (weak, nonatomic) id<OLYCameraRecordingDelegate> recordingDelegate;

/**
 *
 * Indicate that photo shooting is in progress on the camera.
 *
 * When shooting is in progress, the application cannot change the value of the camera properties.
 *
 * @see OLYCamera::startTakingPicture:progressHandler:completionHandler:errorHandler:
 * @see OLYCamera::stopTakingPicture:completionHandler:errorHandler:
 *
 *
 */
@property (assign, nonatomic, readonly) BOOL takingPicture;

/**
 *
 * Indicate that video recording is in progress on the camera.
 *
 * When recording is in progress, the application cannot change the value of the camera properties.
 *
 * @see OLYCamera::startRecordingVideo:completionHandler:errorHandler:
 * @see OLYCamera::stopRecordingVideo:errorHandler:
 * @see OLYCameraRecordingDelegate::cameraDidStopRecordingVideo:
 *
 *
 */
@property (assign, nonatomic, readonly) BOOL recordingVideo;

/**
 *
 * Current focal length of the lens.
 *
 * @see OLYCamera::startDrivingZoomLensForDirection:speed:error:
 * @see OLYCamera::startDrivingZoomLensToFocalLength:error:
 * @see OLYCamera::stopDrivingZoomLens:
 *
 *
 */
@property (assign, nonatomic, readonly) float actualFocalLength;

/**
 *
 * Focal length at the wide end of the lens.
 * This is the shortest focal length of the lens.
 *
 * @see OLYCamera::startDrivingZoomLensForDirection:speed:error:
 * @see OLYCamera::startDrivingZoomLensToFocalLength:error:
 *
 *
 */
@property (assign, nonatomic, readonly) float minimumFocalLength;

/**
 *
 * Focal length at the telephoto end of the lens.
 * This is the longest focal length of the lens.
 *
 * @see OLYCamera::startDrivingZoomLensForDirection:speed:error:
 * @see OLYCamera::startDrivingZoomLensToFocalLength:error:
 *
 *
 */
@property (assign, nonatomic, readonly) float maximumFocalLength;

/**
 *
 * Coordinates focused with autofocus.
 *
 * These coordinates are expressed in viewfinder coordinate system.
 * The application can convert the coordinates in the live view image using
 * the coordinate conversion utility #OLYCameraConvertPointOnViewfinderIntoLiveImage.
 *
 * @see OLYCamera::setAutoFocusPoint:error:
 * @see OLYCamera::clearAutoFocusPoint:
 *
 *
 */
@property (assign, nonatomic, readonly) CGPoint actualAutoFocusPoint;

/**
 *
 * F value used by lens and camera.
 *
 * This value can change depending on the state of the object and
 * the shooting mode.
 * This value can be changed when zooming where the focal length is set to the minimum aperture.
 * Aperture value is set to the minimum value if the value to be set is smaller than the minimum value.
 * Please refer to the documentation of the list of camera properties for more information.
 *
 * This property is set only if the following conditions are met.
 *   - Lens is mounted.
 *   - Run mode is set to recording mode.
 *   - SDK has started receiving live view information. (App does not have to use delegate method.)
 *
 *
 */
@property (strong, nonatomic, readonly) NSString *actualApertureValue;


/**
 *
 * Shutter speed used by the camera.
 *
 * This value can change depending on the state of the object and
 * the shooting mode.
 * Please refer to the documentation of the list of camera properties for more information.
 *
 * This property is set only if the following conditions are met.
 *   - Lens is mounted.
 *   - Run mode is set to recording mode.
 *   - SDK has started receiving live view information. (App does not have to use delegate method.)
 *
 *
 */
@property (strong, nonatomic, readonly) NSString *actualShutterSpeed;

/**
 *
 * Exposure compensation value used by the camera.
 *
 * This value can change depending on the state of the object and
 * the shooting mode.
 * Please refer to the documentation of the list of camera properties for more information.
 *
 * This property is set only if the following conditions are met.
 *   - Lens is mounted.
 *   - Run mode is set to recording mode.
 *   - SDK has started receiving live view information. (App does not have to use delegate method.)
 *
 *
 */
@property (strong, nonatomic, readonly) NSString *actualExposureCompensation;

/**
 *
 * ISO sensitivity used by camera.
 *
 * When ISO sensitivity of the camera property is set to automatic,
 * the value that the camera has chosen will be set.
 * This value can change depending on the state of the object and
 * the shooting mode.
 * Please refer to the documentation of the list of camera properties for more information.
 *
 * This property is set only if the following conditions are met.
 *   - Lens is mounted.
 *   - Run mode is set to recording mode.
 *   - SDK has started receiving live view information. (App does not have to use delegate method.)
 *
 *
 */
@property (strong, nonatomic, readonly) NSString *actualIsoSensitivity;

/**
 *
 * Indicate that out of range warning of ISO sensitivity is occurring in the camera.
 *
 * When shooting during the warning, the image may be underexposed or overexposed.
 *
 *
 */
@property (assign, nonatomic, readonly) BOOL actualIsoSensitivityWarning;

/**
 *
 * Indicate that out of range warning of the exposure is occurring in the camera.
 *
 * The camera can not determine ISO sensitivity, shutter speed or aperture value corresponding
 * to current exposure value.
 * When shooting during the warning, the image may be underexposed or overexposed.
 *
 *
 */
@property (assign, nonatomic, readonly) BOOL exposureWarning;

/**
 *
 * Indicate that warning of the exposure metering is occurring in the camera.
 *
 * Subject is too dark or too bright to be measured by the camera's exposure meter.
 * When shooting during the warning, the image may be underexposed or overexposed.
 *
 *
 */
@property (assign, nonatomic, readonly) BOOL exposureMeteringWarning;

/**
 *
 * Start live view.
 *
 * If live view is not started, some properties cannot update their values, and
 * some methods for taking pictures and recording movies return an error.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::autoStartLiveView
 * @see OLYCamera::stopLiveView:
 *
 *
 */
- (BOOL)startLiveView:(NSError **)error;

/**
 *
 * Stop live view.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::autoStartLiveView
 * @see OLYCamera::startLiveView:
 *
 *
 */
- (BOOL)stopLiveView:(NSError **)error;

/**
 *
 * Change the size of live view.
 *
 * @param size Size of live view.
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 *
 * @see OLYCamera::liveViewSize
 *
 */
- (BOOL)changeLiveViewSize:(OLYCameraLiveViewSize)size error:(NSError **)error;

/**
 *
 * Get the shooting mode and drive mode.
 *
 * The application can determine whether to perform any shooting
 * as a response to a user tap by referring to this value.
 * Please refer to the description of #OLYCameraActionType.
 *
 *
 */
- (OLYCameraActionType)actionType;

/**
 *
 * Start shooting photo.
 *
 * Call this method only when shooting process is not in progress.
 * Do not call this method under movie recoding mode.
 *
 * @param options Optional parameters of the shooting.
 * @param progressHandler Callback used when the download progress changes.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when download is aborted.
 *
 * Optional shooting parameters.
 *   - Set the parameter in dictionary format to customize shooting.
 *     - #OLYCameraStartTakingPictureOptionLimitShootingsKey ... The maximum number of pictures taken by one continuous shooting. Range is 1 to 200, and default is 20.
 *
 * Argument of progressHandler
 *   - progress ... Progress of the photographing operation.
 *   - info ... Focus information is set in the dictionary format at the time of the end of auto focus.
 *     - #OLYCameraTakingPictureProgressInfoFocusResultKey ... Focusing result.
 *       - "ok" ... In focus.
 *       - "ng" ... Did not focus.
 *       - "none" ... AF did not work. Lens is set to MF mode or does not support AF.
 *     - #OLYCameraTakingPictureProgressInfoFocusRectKey ... Rectangular coordinates of focus.
 *       These coordinates are in viewfinder coordinate system.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * The application can convert the rectangular coordinates in live view image using
 * the coordinate conversion utility #OLYCameraConvertRectOnViewfinderIntoLiveImage.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::stopTakingPicture:completionHandler:errorHandler:
 * @see OLYCamera::takePicture:progressHandler:completionHandler:errorHandler:
 *
 *
 */
- (void)startTakingPicture:(NSDictionary *)options progressHandler:(void (^)(OLYCameraTakingProgress progress, NSDictionary *info))progressHandler completionHandler:(void (^)())completionHandler errorHandler:(void (^)(NSError *error))errorHandler;

/**
 *
 * Finish shooting photo.
 *
 * Call this method only when shooting process is in progress.
 * Do not call this method under movie recoding mode.
 *
 * @param progressHandler Callback used when the download progress changes.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when download is aborted.
 *
 * Argument of progressHandler
 *   - progress ... Progress of the photographing operation.
 *   - info ... Not used in current version.
 *
 * Argument of completionHandler
 *   - info ... Not used in current version.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::startTakingPicture:progressHandler:completionHandler:errorHandler:
 * @see OLYCamera::takePicture:progressHandler:completionHandler:errorHandler:
 *
 *
 */
- (void)stopTakingPicture:(void (^)(OLYCameraTakingProgress progress, NSDictionary *info))progressHandler completionHandler:(void (^)(NSDictionary *info))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;

/**
 *
 * Execute batch operation from start of shooting photos to end of shooting.
 *
 * Call this method only when shooting process is not in progress.
 * Do not call this method under movie recoding mode.
 *
 * @param options Optional parameters of the shooting.
 * @param progressHandler Callback used when the download progress changes.
 * @param completionHandler Callback used when download is complete.
 * @param errorHandler Callback used when download is aborted.
 *
 * Optional shooting parameters
 *   - Set the parameter in dictionary format to customize shooting action.
 *     - #OLYCameraStartTakingPictureOptionLimitShootingsKey ... The maximum number of pictures taken by one continuous shooting. Range is 1 to 200, and default is 20.
 *
 * Argument of progressHandler
 *   - progress ... Progress of the photographing operation.
 *   - info ... Focus information is set in dictionary format when auto-focus ends.
 *     - #OLYCameraTakingPictureProgressInfoFocusResultKey ... Focusing result.
 *       - "ok" ... In focus.
 *       - "ng" ... Did not focus.
 *       - "none" ... AF did not work. Lens is set to MF mode or does not support AF.
 *     - #OLYCameraTakingPictureProgressInfoFocusRectKey ... Rectangular coordinates of focus.
 *       Coordinates are in viewfinder coordinate system.
 *
 * Argument of completionHandler
 *   - info ... Not used in current version.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * Application can convert rectangular coordinates in live view image using
 * coordinate conversion utility #OLYCameraConvertRectOnViewfinderIntoLiveImage.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::startTakingPicture:progressHandler:completionHandler:errorHandler:
 * @see OLYCamera::stopTakingPicture:completionHandler:errorHandler:
 *
 *
 */
- (void)takePicture:(NSDictionary *)options progressHandler:(void (^)(OLYCameraTakingProgress progress, NSDictionary *info))progressHandler completionHandler:(void (^)(NSDictionary *info))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;

/**
 *
 * Start recording movie.
 *
 * Call this method only when recording process is not in progress.
 * Do not call this method under still image shooting mode.
 *
 * @param options Not used in current version.
 * @param completionHandler Callback used when start of recording is complete.
 * @param errorHandler Callback used when the start of recording is aborted.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when operation is abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::stopRecordingVideo:errorHandler:
 * @see OLYCameraRecordingDelegate::cameraDidStopRecordingVideo:
 *
 *
 */
- (void)startRecordingVideo:(NSDictionary *)options completionHandler:(void (^)())completionHandler errorHandler:(void (^)(NSError *error))errorHandler;

/**
 *
 * Finish recording movie.
 *
 * Call this method only when recording process is in progress.
 * Do not call this method under still image shooting mode.
 *
 * @param completionHandler Callback used when end of recording is complete.
 * @param errorHandler Callback used when end of recording is aborted.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::startRecordingVideo:completionHandler:errorHandler:
 * @see OLYCameraRecordingDelegate::cameraDidStopRecordingVideo:
 *
 *
 */
- (void)stopRecordingVideo:(void (^)(NSDictionary *info))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;

/**
 *
 * Lock autofocus operation.
 *
 * Focus the camera to the specified coordinates, and then lock so that focus does not later change.
 * The application must have previously set the coordinates for auto focus.
 * The application must call unlock to resume auto focus.
 *
 * @param completionHandler Callback used when lock is complete.
 * @param errorHandler Callback used when lock was aborted.
 *
 * Argument of completionHandler
 *   - info ... Focus information is set in dictionary format at the time of the S-AF modes of auto focus.
 *     - #OLYCameraTakingPictureProgressInfoFocusResultKey ... Focusing result.
 *       - "ok" ... In focus.
 *       - "ng" ... Did not focus.
 *       - "none" ... AF did not work. Lens is set to MF mode or does not support AF.
 *     - #OLYCameraTakingPictureProgressInfoFocusRectKey ... Rectangular coordinates of focus.
 *       Coordinates are in viewfinder coordinate system.
 *
 * Argument of errorHandler
 *   - error ... Error details are set when the operation is abnormally terminated.
 *
 * The application can convert rectangular coordinates in live view image using
 * the coordinate conversion utility #OLYCameraConvertRectOnViewfinderIntoLiveImage.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::setAutoFocusPoint:error:
 * @see OLYCamera::unlockAutoFocus:
 * @see OLYCameraRecordingDelegate::camera:didChangeAutoFocusResult:
 *
 *
 */
- (void)lockAutoFocus:(void (^)(NSDictionary *info))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;

/**
 *
 * Unlock autofocus operation.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::lockAutoFocus:errorHandler:
 *
 *
 */
- (BOOL)unlockAutoFocus:(NSError **)error;

/**
 *
 * Set coordinates to use for auto focus.
 *
 * Prior to locking focus,
 * the application sets the coordinates to focus with this method.
 * The application will get an error if value exceeds the valid range of focus coordinates.
 *
 * @param point Coordinates where to focus.
 * Coordinates are in viewfinder coordinate system.
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * The application can convert the focusing coordinates from coordinates in live view image
 * using the coordinate conversion utility #OLYCameraConvertPointOnLiveImageIntoViewfinder.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::lockAutoFocus:errorHandler:
 * @see OLYCamera::autoFocusEffectiveArea:
 * @see OLYCameraRecordingDelegate::camera:didChangeAutoFocusResult:
 *
 *
 */
- (BOOL)setAutoFocusPoint:(CGPoint)point error:(NSError **)error;

/**
 *
 * Clear coordinates used for auto focus.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::setAutoFocusPoint:error:
 *
 *
 */
- (BOOL)clearAutoFocusPoint:(NSError **)error;

/**
 *
 * Lock operation of automatic exposure control.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::unlockAutoExposure:
 *
 *
 */
- (BOOL)lockAutoExposure:(NSError **)error;

/**
 *
 * Release lock of automatic exposure control.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::lockAutoExposure:
 *
 *
 */
- (BOOL)unlockAutoExposure:(NSError **)error;

/**
 *
 * Specify coordinates of reference exposure for automatic exposure control.
 *
 * Application must set coordinates with this method prior
 * to locking automatic exposure control.
 * Application will get an error if value exceeds the valid range of target coordinates.
 *
 * Set camera property "AE" to "AE_PINPOINT" before calling this method.
 *
 * @param point Target coordinates.
 * Coordinates are in viewfinder coordinate system.
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * Application can convert the focusing coordinates from the coordinates in live view image
 * using the coordinate conversion utility #OLYCameraConvertPointOnLiveImageIntoViewfinder.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::clearAutoExposurePoint:
 * @see OLYCamera::autoExposureEffectiveArea:
 *
 *
 */
- (BOOL)setAutoExposurePoint:(CGPoint)point error:(NSError **)error;

/**
 *
 * Release specified coordinates of reference exposure for automatic exposure control.
 *
 * Set camera property "AE" to "AE_PINPOINT" before calling this method.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::setAutoExposurePoint:error:
 *
 *
 */
- (BOOL)clearAutoExposurePoint:(NSError **)error;

/**
 *
 * Get valid range of coordinates to use for auto focus.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return Rectangular coordinates indicating the effective range.
 * Coordinates are in viewfinder coordinate system.
 *
 * The application can convert to rectangular coordinates from live view image in the rectangular coordinates
 * indicating the range using the coordinate conversion utility #OLYCameraConvertRectOnViewfinderIntoLiveImage.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::setAutoFocusPoint:error:
 *
 *
 */
- (CGRect)autoFocusEffectiveArea:(NSError **)error;

/**
 *
 * Get valid range of coordinates to use for automatic exposure control.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return Rectangular coordinates indicating the effective range.
 * Coordinates are in viewfinder coordinate system.
 *
 * The application can convert to rectangular coordinates for live view image on the rectangular coordinates
 * indicating the range using the coordinate conversion utility #OLYCameraConvertRectOnViewfinderIntoLiveImage.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::setAutoExposurePoint:error:
 *
 *
 */
- (CGRect)autoExposureEffectiveArea:(NSError **)error;

@end

#pragma mark -
#pragma mark Related Delegates

/**
 *
 * Delegate to notify state of live view image when it changes.
 *
 *
 */
@protocol OLYCameraLiveViewDelegate <NSObject>
@optional

/**
 *
 * Notify that image for live view is updated.
 *
 * The application's live view can be updated in real time by using an image that has been attached to this notice.
 *
 * @param camera Instance that detects change in live view.
 * @param data Image of the new live view.
 * @param metadata Metadata of the image of the new live view.
 *
 *
 */
- (void)camera:(OLYCamera *)camera didUpdateLiveView:(NSData *)data metadata:(NSDictionary *)metadata;

@end

#pragma mark -
#pragma mark Related Delegates

/**
 *
 * Delegate to notify camera state when it changes.
 * The camera state relates to capturing operation which affects still image or movie.
 *
 *
 */
@protocol OLYCameraRecordingDelegate <NSObject>
@optional

/**
 *
 * Notify that recording was started from the camera side.
 *
 * @param camera Instance that detects the camera starts recording.
 *
 *
 *
 */
- (void)cameraDidStartRecordingVideo:(OLYCamera *)camera;

/**
 *
 * Notify that recording was stopped from the camera side.
 *
 * The following are possible causes.
 *   - Recording time reaches specified time.
 *   - Memory card becomes full during recording.
 *
 * @param camera Instance that detects the camera stops recording
 *
 *
 */
- (void)cameraDidStopRecordingVideo:(OLYCamera *)camera;

/**
 *
 * Notify result of auto focus when it changes.
 *
 * @param camera Instances it is detected that the focus result changes.
 * @param result Focusing result.
 *
 * Focusing result is passed in dictionary format.
 *   - #OLYCameraTakingPictureProgressInfoFocusResultKey ... Focusing result.
 *     - "ok" ... In focus.
 *     - "ng" ... Did not focus.
 *     - "none" ... AF did not work. Lens is set to MF mode or does not support AF.
 *   - #OLYCameraTakingPictureProgressInfoFocusRectKey ... Rectangular coordinates for focus.
 *     Coordinates are in viewfinder coordinate system.
 *
 * The application can convert the rectangular coordinates in live view image using
 * the coordinate conversion utility #OLYCameraConvertRectOnViewfinderIntoLiveImage.
 *
 *
 */
- (void)camera:(OLYCamera *)camera didChangeAutoFocusResult:(NSDictionary *)result;

@end

// EOF

// #import "OLYCamera+RecordingSupports.h"
/**
 *
 * @file    OLYCamera+RecordingSupports.h
 * @brief   OLYCamera(RecordingSupports) class interface file.
 *
 *
 */
/*
 * Copyright (c) Olympus Imaging Corporation. All rights reserved.
 * Olympus Imaging Corp. licenses this software to you under EULA_OlympusCameraKit_ForDevelopers.pdf.
 */

/**
 *
 * @defgroup types Types
 *
 * Type definition and enumerated types that are to be used by Olympus camera class
 *
 *
 * @{
 */
/**
 *
 * @name Olympus camera class: recording auxiliary category
 *
 *
 * @{
 */

/**
 *
 * Driving direction of optical zoom.
 *
 *
 */
enum OLYCameraDrivingZoomLensDirection {
    /**
     * Towards the wide end (zoom out).
     *
     */
    OLYCameraDrivingZoomLensWide,

    /**
     * Towards the telephoto end (zoom in).
     *
     */
    OLYCameraDrivingZoomLensTele,
};
typedef enum OLYCameraDrivingZoomLensDirection OLYCameraDrivingZoomLensDirection;

/**
 * Driving speed of optical zoom.
 *
 */
enum OLYCameraDrivingZoomLensSpeed {
    /**
     * Zoom at low speed.
     *
     */
    OLYCameraDrivingZoomLensSpeedSlow,

    /**
     * Zoom at high speed.
     *
     */
    OLYCameraDrivingZoomLensSpeedFast,

    /**
     * Zoom at medium speed.
     *
     */
    OLYCameraDrivingZoomLensSpeedNormal,

    /**
     * Zoom to wide or telephoto end at once.
     *
     *
     */
    OLYCameraDrivingZoomLensSpeedBurst,
};
typedef enum OLYCameraDrivingZoomLensSpeed OLYCameraDrivingZoomLensSpeed;

/**
 * Magnification of live view.
 *
 */
enum OLYCameraMagnifyingLiveViewScale {
    /**
     * 5x magnification.
     *
     */
    OLYCameraMagnifyingLiveViewScaleX5,

    /**
     * 7x magnification.
     *
     */
    OLYCameraMagnifyingLiveViewScaleX7,

    /**
     * 10x magnification.
     *
     */
    OLYCameraMagnifyingLiveViewScaleX10,

    /**
     * 14x magnification.
     *
     */
    OLYCameraMagnifyingLiveViewScaleX14,
};
typedef enum OLYCameraMagnifyingLiveViewScale OLYCameraMagnifyingLiveViewScale;

/**
 * Scroll direction in magnified live view.
 *
 */
enum OLYCameraMagnifyingLiveViewScrollDirection {
    /**
     * Scroll up.
     *
     */
    OLYCameraMagnifyingLiveViewScrollDirectionUp,

    /**
     * Scroll left.
     *
     */
    OLYCameraMagnifyingLiveViewScrollDirectionLeft,

    /**
     * Scroll right.
     *
     */
    OLYCameraMagnifyingLiveViewScrollDirectionRight,

    /**
     * Scroll down.
     *
     */
    OLYCameraMagnifyingLiveViewScrollDirectionDown,
};
typedef enum OLYCameraMagnifyingLiveViewScrollDirection OLYCameraMagnifyingLiveViewScrollDirection;

/** @} */
/** @} */

/**
 *
 * @defgroup constants Constants
 *
 * Constants referenced by Olympus camera class
 *
 *
 * @{
 */
/**
 *
 * @name Olympus camera class: recording auxiliary category
 *
 *
 * @{
 */

/**
 * Dictionary key for accessing 'Orientation' elements of the level gauge information.
 */
extern NSString *const OLYCameraLevelGaugeOrientationKey;

/**
 * Dictionary key for accessing 'Roll' elements of the level gauge information.
 * 'Roll' is rotation around the optical axis.
 */
extern NSString *const OLYCameraLevelGaugeRollingKey;

/**
 * Dictionary key for accessing 'Pitch' elements of the level gauge information.
 * 'Pitch' describes the camera is pointed up or down.
 */
extern NSString *const OLYCameraLevelGaugePitchingKey;

/**
 * Dictionary key for accessing 'Minimum zoom scale' elements of the level gauge information.
 */
extern NSString *const OLYCameraDigitalZoomScaleRangeMinimumKey;

/**
 * Dictionary key to access 'Maximum zoom scale' elements of the digital zoom information.
 */
extern NSString *const OLYCameraDigitalZoomScaleRangeMaximumKey;

/**
 * Dictionary key for accessing 'Overall view' elements of the magnified live view information.
 */
extern NSString *const OLYCameraMagnifyingOverallViewSizeKey;

/**
 * Dictionary key for accessing 'Display area' elements of the magnified live view information.
 */
extern NSString *const OLYCameraMagnifyingDisplayAreaRectKey;

/** @} */
/** @} */

@protocol OLYCameraRecordingSupportsDelegate;

#pragma mark -

/**
 *
 * Recording auxiliary category of Olympus camera class.
 *
 * This category provides zoom control.
 *
 *
 * @category OLYCamera(RecordingSupports)
 */
@interface OLYCamera(RecordingSupports)

/**
 *
 * Delegate object to notify camera state when it changes.
 * The camera state relates to capturing operation which affects still image or movie.
 *
 *
 */
@property (weak, nonatomic) id<OLYCameraRecordingSupportsDelegate> recordingSupportsDelegate;

/**
 *
 * Indicate optical zoom is changing in the camera.
 *
 * @see OLYCamera::startDrivingZoomLensForDirection:speed:error:
 * @see OLYCamera::startDrivingZoomLensToFocalLength:error:
 * @see OLYCamera::stopDrivingZoomLens:
 * @see OLYCameraRecordingSupportsDelegate::cameraDidStopDrivingZoomLens:
 *
 *
 */
@property (assign, nonatomic, readonly) BOOL drivingZoomLens;

/**
 *
 * Indicate that live view is magnified.
 *
 * @see OLYCamera::startMagnifyingLiveView:error:
 * @see OLYCamera::startMagnifyingLiveViewAtPoint:scale:error:
 * @see OLYCamera::stopMagnifyingLiveView:
 *
 *
 */
@property (assign, nonatomic, readonly) BOOL magnifyingLiveView;

/**
 *
 * Information of level gauge.
 *
 * The following information is included.
 *   - #OLYCameraLevelGaugeOrientationKey ... Inclination and orientation on the camera body.
 *     - "landscape" ... Lens mount tilt is 0 degrees.
 *       Camera body is in horizontal direction.
 *       This is the normal state.
 *     - "portrait_left" ... Lens mount tilt is 90 degrees clockwise.
 *       Camera body is in horizontal direction.
 *     - "landscape_upside_down" ... Lens mount tilt is 180 degrees.
 *       Camera body is in horizontal direction.
 *       This is upside down state.
 *     - "portrait_right" ... Lens mount tilt is 270 degrees clockwise.
 *       Camera body is in horizontal direction.
 *     - "faceup" ...  The camera is pointed up. Horizontal orientation is undefined.
 *     - "facedown" ... The camera is pointed down. Horizontal orientation is undefined.
 *   - #OLYCameraLevelGaugeRollingKey ... Roll angle in degrees of the camera body relative to horizontal.
 *     If the angle cannot be determined, NaN is returned.
 *   - #OLYCameraLevelGaugePitchingKey ... Pitch angle in degrees of the camera body relative to horizontal.
 *     If the angle cannot be determined, NaN is returned.
 *
 * This property is set only if the following conditions are met.
 *   - Run mode is set to recording mode.
 *   - SDK has started receiving live view information. (App does not have to use delegate method.)
 *
 *
 */
@property (strong, nonatomic, readonly) NSDictionary *levelGauge;

/**
 *
 * Face recognition results.
 *
 * Coordinate information of face detected by the camera is stored in dictionary format.
 * The dictionary key is a string that represents the identification number.
 * It is not possible to track the coordinates of a recognized face by relying on a specific identification number.
 *
 * This property is set only if the following conditions are met.
 *   - Run mode is set to recording mode.
 *   - SDK has started receiving live view information. (App does not have to use delegate method.)
 *
 *
 */
@property (strong, nonatomic, readonly) NSDictionary *detectedHumanFaces;

/**
 *
 * Start driving optical zoom with specific speed and direction.
 *
 * Lens attached to the camera must support electric zoom.
 * If the optical zoom is already being driven, application will get an error.
 *
 * @param direction Driving direction.
 * @param speed Driving speed.
 * @param error Error details are set when the operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::lensMountStatus
 * @see OLYCamera::drivingZoomLens
 * @see OLYCameraRecordingSupportsDelegate::cameraDidStopDrivingZoomLens:
 *
 *
 */
- (BOOL)startDrivingZoomLensForDirection:(OLYCameraDrivingZoomLensDirection)direction speed:(OLYCameraDrivingZoomLensSpeed)speed error:(NSError **)error;

/**
 *
 * Start driving optical zoom to the specified focal length.
 *
 * Lens attached to the camera must support electric zoom.
 * If the optical zoom is already being driven, application will get an error.
 *
 * @param focalLength Focal length.
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::lensMountStatus
 * @see OLYCamera::drivingZoomLens
 * @see OLYCameraRecordingSupportsDelegate::cameraDidStopDrivingZoomLens:
 *
 *
 */
- (BOOL)startDrivingZoomLensToFocalLength:(float)focalLength error:(NSError **)error;

/**
 *
 * Stop driving optical zoom.
 *
 * Lens attached to the camera must support electric zoom.
 * If the optical zoom is already being driven, application will get an error.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::lensMountStatus
 * @see OLYCamera::drivingZoomLens
 *
 *
 */
- (BOOL)stopDrivingZoomLens:(NSError **)error;

/**
 *
 * Get configurable magnification range of digital zoom.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return Configurable range. The acquired information is in dictionary format.
 *
 * The following information is included.
 *  - #OLYCameraDigitalZoomScaleRangeMinimumKey ... Minimum magnification.
 *  - #OLYCameraDigitalZoomScaleRangeMaximumKey ... Maximum magnification.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::changeDigitalZoomScale:error:
 *
 *
 */
- (NSDictionary *)digitalZoomScaleRange:(NSError **)error;

/**
 *
 * Change magnification of digital zoom.
 *
 * If application specifies magnification that is not included in the configurable range,
 * there will be an error.
 * When changing run mode to any mode except recording mode, magnification is changed back to 1x automatically.
 *
 * @param scale Magnification of digital zoom.
 * @param error Error details are set when the operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::digitalZoomScaleRange:
 *
 *
 */
- (BOOL)changeDigitalZoomScale:(float)scale error:(NSError **)error;

/**
 *
 * Start magnifying live view.
 *
 * If live view is already magnified, an error occurs.
 *
 * @param scale Magnification of live view.
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::magnifyingLiveView
 * @see OLYCamera::startMagnifyingLiveViewAtPoint:scale:error:
 * @see OLYCamera::stopMagnifyingLiveView:
 *
 *
 */
- (BOOL)startMagnifyingLiveView:(OLYCameraMagnifyingLiveViewScale)scale error:(NSError **)error;

/**
 *
 * Start magnifying live view with center coordinate of magnification.
 *
 * If live view is already magnified, an error occurs.
 *
 * @param point Center coordinate of the magnified display in viewfinder coordinate system.
 * The viewfinder coordinate system is explained in coordinate conversion utilities section of functions menu.
 * @param scale Magnification of live view.
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::magnifyingLiveView
 * @see OLYCamera::startMagnifyingLiveView:error:
 * @see OLYCamera::stopMagnifyingLiveView:
 *
 *
 */
- (BOOL)startMagnifyingLiveViewAtPoint:(CGPoint)point scale:(OLYCameraMagnifyingLiveViewScale)scale error:(NSError **)error;

/**
 *
 * Stop magnifying live view.
 *
 * If live view is not magnified, an error occurs.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::magnifyingLiveView
 * @see OLYCamera::startMagnifyingLiveView:error:
 * @see OLYCamera::startMagnifyingLiveViewAtPoint:scale:error:
 *
 *
 */
- (BOOL)stopMagnifyingLiveView:(NSError **)error;

/**
 *
 * Change magnification of live view.
 *
 * If live view is not magnified, an error occurs.
 *
 * @param scale Magnification of live view.
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::magnifyingLiveView
 * @see OLYCamera::startMagnifyingLiveView:error:
 * @see OLYCamera::startMagnifyingLiveViewAtPoint:scale:error:
 * @see OLYCamera::stopMagnifyingLiveView:
 *
 *
 */
- (BOOL)changeMagnifyingLiveViewScale:(OLYCameraMagnifyingLiveViewScale)scale error:(NSError **)error;

/**
 *
 * Move display area in magnified live view.
 *
 * If live view is not magnified, an error occurs.
 *
 * @param direction Scrolling direction of the display area.
 * @param error Error details are set when operation is abnormally terminated.
 * @return If true, operation was successful. If false, operation was abnormally terminated.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @see OLYCamera::magnifyingLiveView
 * @see OLYCamera::startMagnifyingLiveView:error:
 * @see OLYCamera::startMagnifyingLiveViewAtPoint:scale:error:
 * @see OLYCamera::stopMagnifyingLiveView:
 * @see OLYCamera::magnifyingLiveViewArea:
 *
 *
 */
- (BOOL)changeMagnifyingLiveViewArea:(OLYCameraMagnifyingLiveViewScrollDirection)direction error:(NSError **)error;

/**
 *
 * Get display area information of magnified live view.
 *
 * If live view is not magnified, an error occurs.
 *
 * @param error Error details are set when operation is abnormally terminated.
 * @return Display area information in the dictionary format.
 *   - #OLYCameraMagnifyingOverallViewSizeKey ... Size of the overall view.
 *   - #OLYCameraMagnifyingDisplayAreaRectKey ... Rectangular coordinates of the display area in viewfinder coordinate system. The viewfinder coordinate system is explained in coordinate conversion utilities section of functions menu.
 *
 * @par Supported run mode(s)
 * This method call is allowed only in following run mode and otherwise causes an error.
 *   - #OLYCameraRunModeRecording
 *
 * @par Availability
 *   - Camera firmware: Version 1.1 or later.
 *
 * @see OLYCamera::magnifyingLiveView
 * @see OLYCamera::startMagnifyingLiveView:error:
 * @see OLYCamera::startMagnifyingLiveViewAtPoint:scale:error:
 * @see OLYCamera::stopMagnifyingLiveView:
 * @see OLYCamera::changeMagnifyingLiveViewArea:error:
 *
 *
 */
- (NSDictionary *)magnifyingLiveViewArea:(NSError **)error;

// ;-)

@end

#pragma mark -
#pragma mark Related Delegates

/**
 *
 * Delegate to notify camera state when it changes.
 * The camera state relates to capturing operation which do not affect still image or movie.
 *
 *
 */
@protocol OLYCameraRecordingSupportsDelegate <NSObject>
@optional

/**
 *
 * Notify that SDK will receive preview image.
 *
 * Application is notified when preview image generated and camera property "RECVIEW" is set to "ON".
 * Please refer to the documentation of the list of camera properties for more information.
 *
 * The preview image is generated after:
 *  - Application starts shooting.
 *  - User presses shutter button.
 *
 * @param camera Instance that receives the image.
 *
 *
 */
- (void)cameraWillReceiveCapturedImagePreview:(OLYCamera *)camera;

/**
 *
 * Notify that SDK receives preview image.
 *
 * Application is notified when preview image generated and camera property "RECVIEW" is set to "ON".
 * Please refer to the documentation of the list of camera properties for more information.
 *
 * The preview image is generated after:
 *  - Application starts shooting.
 *  - User presses shutter button.
 *
 * @param camera Instance that receives the image.
 * @param data Captured image for preview.
 * @param metadata Metadata of captured image for preview.
 *
 * There are cases where the following information is included in metadata with EXIF information.
 *     - "detectversion" ... Reserved for vendor.
 *     - "detectid" ... Reserved for vendor.
 *
 *
 */
- (void)camera:(OLYCamera *)camera didReceiveCapturedImagePreview:(NSData *)data metadata:(NSDictionary *)metadata;

/**
 *
 * Notify that SDK fails to receive preview image.
 *
 * @param camera Instance that fails to receive the preview image.
 * @param error Error details.
 *
 *
 */
- (void)camera:(OLYCamera *)camera didFailToReceiveCapturedImagePreviewWithError:(NSError *)error;

/**
 *
 * Notify that SDK will receive original size image after shooting.
 *
 * This is notified at the end of the shot if camera property "DESTINATION_FILE" is set to "DESTINATION_FILE_WIFI".
 * Please refer to the documentation of the list of camera properties for more information.
 *
 * @param camera Instance that receives the image data.
 *
 *
 */
- (void)cameraWillReceiveCapturedImage:(OLYCamera *)camera;

/**
 *
 * Notify that SDK receives original size image after shooting.
 *
 * This is notified at the end of the shot if camera property "DESTINATION_FILE" is set to "DESTINATION_FILE_WIFI".
 * Please refer to the documentation of the list of camera properties for more information.
 *
 * @param camera Instance that receives the image data.
 * @param data Captured image for storage.
 *
 *
 */
- (void)camera:(OLYCamera *)camera didReceiveCapturedImage:(NSData *)data;

/**
 *
 * Notify that SDK will not receive original size image after shooting.
 *
 * @param camera Instance that fails to receive the image.
 * @param error Error details.
 *
 *
 */
- (void)camera:(OLYCamera *)camera didFailToReceiveCapturedImageWithError:(NSError *)error;

/**
 *
 * Notify that the driving of the optical zoom is stopped due to reasons on camera side.
 *
 * This may be caused by the lens reaching the maximum or minimum zoom before calling to stop optical zoom.
 *
 * @param camera Instance that detects the camera stops recording.
 *
 *
 */
- (void)cameraDidStopDrivingZoomLens:(OLYCamera *)camera;

@end

// EOF

// #import "OLYCamera+Maintenance.h"
/**
 *
 * @file    OLYCamera+Maintenance.h
 * @brief   OLYCamera(Maintenance) class interface file.
 *
 *
 */
/*
 * Copyright (c) Olympus Imaging Corporation. All rights reserved.
 * Olympus Imaging Corp. licenses this software to you under EULA_OlympusCameraKit_ForDevelopers.pdf.
 */

/**
 *
 * @defgroup constants Constants
 *
 * Constants referenced by Olympus camera class
 *
 *
 * @{
 */
/**
 *
 * @name Olympus camera class: maintenance category
 *
 *
 * @{
 */

// ;-)

// ;-)

// ;-)

// ;-)

/** @} */
/** @} */

#pragma mark -

/**
 *
 * Maintenance category of Olympus camera class.
 *
 * This category provides no functions and is reserved for future expansion.
 *
 *
 * @category OLYCamera(Maintenance)
 */
@interface OLYCamera(Maintenance)

// ;-)

// ;-)

// ;-)

// ;-)

// ;-)

// ;-)

// ;-)

@end

// EOF

// #import "OLYCamera+Functions.h"
/**
 *
 * @file    OLYCamera+Functions.h
 * @brief   OLYCamera function interface file.
 *
 *
 */
/*
 * Copyright (c) Olympus Imaging Corporation. All rights reserved.
 * Olympus Imaging Corp. licenses this software to you under EULA_OlympusCameraKit_ForDevelopers.pdf.
 */

/**
 *
 * @defgroup functions Functions
 *
 * Support functions for Olympus camera class
 *
 *
 * @{
 */

#pragma mark Image Processing Utilities

/**
 *
 * @name Image processing utilities
 *
 *
 * @{
 */

/**
 *
 * Convert image data to UIImage object.
 *
 * @param data Image data
 * @param metadata Metadata of image data.
 * @return UIImage object generated from image data.
 *
 *
 */
UIImage *OLYCameraConvertDataToImage(NSData *data, NSDictionary *metadata);

/** @} */

#pragma mark Coordinate Conversion Utilities

/**
 *
 * @name Coordinate conversion utilities
 *
 * These utilities convert between
 * coordinates in viewfinder coordinate system and
 * coordinates in live view coordinate system.
 *
 * Live view coordinate system is in units of pixels for live view image.
 * The origin is the upper-left corner.
 * Vertical and horizontal coordinate axes match the image display of the smartphone.
 * If camera is rotated into portrait orientation, the origin is still in the upper-left,
 * but the width and height of the image are changed since image is rotated.
 * Live view coordinates are used to represent a pixel position on the image when user touches the live view.
 *
 * Viewfinder coordinate system is normalized to width = 1.0 and height = 1.0 for live view image.
 * The origin is the upper-left corner.
 * Vertical and horizontal coordinate axes correspond to image sensor in camera.
 * If camera is rotated into portrait or landscape mode,
 * there is no change to the image width and height or the picture rotation.
 * Viewfinder coordinate system is used to represent the in-focus position and the position of the specified auto focus lock.
 *
 *
 * @{
 */

/**
 *
 * Convert coordinates in live view coordinate system
 * into coordinates in viewfinder coordinate system.
 *
 * @param point Coordinates in live view coordinate system.
 * @param liveImage Live view image.
 * @return Coordinates in viewfinder coordinate system.
 *
 *
 */
CGPoint OLYCameraConvertPointOnLiveImageIntoViewfinder(CGPoint point, UIImage *liveImage);

/**
 *
 * Convert coordinates in viewfinder coordinate system
 * into coordinates in live view coordinate system.
 *
 * @param point Coordinates in viewfinder coordinate system.
 * @param liveImage Live view image.
 * @return Coordinates in live view coordinate system.
 *
 *
 */
CGPoint OLYCameraConvertPointOnViewfinderIntoLiveImage(CGPoint point, UIImage *liveImage);

/**
 *
 * Convert rectangular coordinates in live view coordinate system
 * into the rectangular coordinates in viewfinder coordinate system.
 * This method is used to convert coordinates of auto focus frame for example.
 *
 * @param rect Rectangular coordinates in live view coordinate system.
 * @param liveImage Live view image.
 * @return Rectangular coordinates in viewfinder coordinate system.
 *
 *
 */
CGRect OLYCameraConvertRectOnLiveImageIntoViewfinder(CGRect rect, UIImage *liveImage);

/**
 *
 * Convert rectangular coordinates in viewfinder coordinate system
 * into rectangular coordinates in live view coordinate system.
 * This method is used to convert coordinates of auto focus frame for example.
 *
 * @param rect Rectangular coordinates in viewfinder coordinate system.
 * @param liveImage Live view image.
 * @return Rectangular coordinates in live view coordinate system.
 *
 *
 */
CGRect OLYCameraConvertRectOnViewfinderIntoLiveImage(CGRect rect, UIImage *liveImage);

/** @} */

/** @} */

// EOF

// EOF









