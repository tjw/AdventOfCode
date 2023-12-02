import Foundation

let lines = Input.lines()

struct Group {
    var red: Int = 0
    var green: Int = 0
    var blue: Int = 0
}
struct Game {
    let id: Int
    var groups = [Group]()

    init(line: String) {
        let items = line.split(separator: ":")
        assert(items.count == 2)

        self.id = Int(items[0].split(separator: " ").last!)!

        var groups = [Group]()
        items[1].split(separator: ";").forEach { groupString in
            var group = Group()

            groupString.split(separator: ",").forEach { colorString in
                let colorItems = colorString.trimmingCharacters(in: .whitespaces).split(separator: " ")
                let count = Int(colorItems[0])!
                let color = colorItems[1]

                switch color {
                case "red":
                    group.red += count
                case "green":
                    group.green += count
                case "blue":
                    group.blue += count
                default:
                    fatalError("Unknown color")
                }
            }

            groups.append(group)
        }
        self.groups = groups
    }
}

let games = lines.map { Game(line: $0) }

do {
    let permitted = games.filter { game in
        !game.groups.contains {
            $0.red > 12 ||
            $0.green > 13 ||
            $0.blue > 14
        }
    }

    let result = permitted.reduce(0, { $0 + $1.id })
    print("\(result)")
    assert(result == 2369)
}


