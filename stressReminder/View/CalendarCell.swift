//
//  CalendarCell.swift
//  stressReminder
//
//  Created by workspace on 2025/04/20.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    private let dayLabel = UILabel()
    private let dateLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        dayLabel.font = .systemFont(ofSize: 12)
        dayLabel.textAlignment = .center

        dateLabel.font = .boldSystemFont(ofSize: 16)
        dateLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [dayLabel, dateLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with date: Date, selected: Bool) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")

        formatter.dateFormat = "E"
        dayLabel.text = formatter.string(from: date)

        formatter.dateFormat = "d"
        dateLabel.text = formatter.string(from: date)

        contentView.backgroundColor = selected ? .systemYellow : .secondarySystemBackground
    }
}
