JoGallery
==============

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/djangolee/JoGallery/master/LICENSE)
[![Build Status](https://travis-ci.org/djangolee/JoGallery.svg?branch=master)](https://travis-ci.org/djangolee/JoGallery)
[![CocoaPods](https://img.shields.io/cocoapods/v/JoGallery.svg)](http://cocoapods.org/?q=JoGallery)
[![Support](https://img.shields.io/badge/support-iOS8-blue.svg?style=flat)](https://www.apple.com/nl/ios/)
[![Language](https://img.shields.io/badge/language-Swift3.1-orange.svg)](https://swift.org/)

Example Project
==============

<img src="https://github.com/djangolee/DataBase-for-Image/blob/master/JoGallery/JoGallery.3.gif" width="290"> <img src="https://github.com/djangolee/DataBase-for-Image/blob/master/JoGallery/JoGallery.4.gif" width="290"> <img src="https://github.com/djangolee/DataBase-for-Image/blob/master/JoGallery/JoGallery.6.gif" width="290">


Installation
==============

### CocoaPods

1. Add `pod 'JoGallery'` to your Podfile.
2. Run `pod install` or `pod update`.
3. Import JoGallery


Usage
==============

### Init
    let controller = JoGalleryController()
    controller.register(JoGalleryCell.self, forCellWithReuseIdentifier: ...)
    controller.delegate = ...
    controller.dataSource = ...

### Show
    controller.present(from: VC, toItem: indexPath)

### JoGalleryDataSource

    func galleryController(_ galleryController: JoGalleryController, numberOfItemsInSection section: Int) -> Int {
        return ...
    }

    func galleryController(_ galleryController: JoGalleryController, cellForItemAt indexPath: IndexPath) -> JoGalleryCell{

        let cell = galleryController.dequeueReusableCell(withReuseIdentifier: ...), for: indexPath)
        ...
        return cell
    }

### JoGalleryDelegate

    func presentForTransitioning(in galleryController: JoGalleryController, openAt indexPath: IndexPath) -> JoGalleryLocationAttributes? {
        ...
        return (view, content)
    }

    func dismissForTransitioning(in galleryController: JoGalleryController, closeAt indexPath: IndexPath) -> JoGalleryLocationAttributes? {
        ...
        return (view, content)
    }

    func galleryBeginTransforming(in galleryController: JoGalleryController, atIndex indexPath: IndexPath) -> UIView? {
        ...
        return locationView
    }

    func galleryDidEndTransforming(in galleryController: JoGalleryController, atIndex indexPath: IndexPath, with thresholdValue: CGFloat) -> UIView? {
        ...
        return locationView
    }

    func gallery(_ galleryController: JoGalleryController, scrolDidDisplay cell: JoGalleryCell, forItemAt indexPath: IndexPath, oldItemFrom oldIndexPath: IndexPath) {
        // scroll to location
        ...
    }
