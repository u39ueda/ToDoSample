//
//  main.swift
//  ToDoSample
//
//  Created by Yusaku Ueda on 2018/08/07.
//  Copyright © 2018年 Yusaku Ueda. All rights reserved.
//

import UIKit

// 通常なら単体テストの時もアプリが起動してしまうが、単体テストの時はダミーのAppDelegateを使用することでアプリが起動しないようにする.
// TestingAppDelegateクラスは単体テスト時のみ存在するので、それで単体テストかを判定する.
let appDelegateClass: AnyClass? = NSClassFromString("ToDoSampleTests.TestingAppDelegate") ?? AppDelegate.self
let args = UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to: UnsafeMutablePointer<Int8>.self, capacity: Int(CommandLine.argc))
UIApplicationMain(CommandLine.argc, args, nil, NSStringFromClass(appDelegateClass!))
