//
//  TabBarController.swift
//  Tracker
//
//  Created by Данил Третьяченко on 12.05.2026.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настраиваем внешний вид таб-бара
        tabBar.backgroundColor = .white
        tabBar.tintColor = .systemBlue // Цвет активной иконки
        
        // Создаем первый экран (Трекеры) в обертке NavigationController
        let trackersVC = UINavigationController(rootViewController: TrackersViewController())
        trackersVC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill"),
            tag: 0
        )
        
        // Создаем второй экран (Статистика)
        let statsVC = UINavigationController(rootViewController: StatisticsViewController())
        statsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"),
            tag: 1
        )
        
        // Добавляем их в массив контроллеров таб-бара
        viewControllers = [trackersVC, statsVC]
    }
}
