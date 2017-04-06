class StylingDescriptorBuilder {
    fileprivate var openingStylingDescriptors: [String] {
        get {
            return [
                "[1m",
                "[0;32m",
                "[31m",
                "[32m",
                "[33m",
                "[36m",
                "[91m",
                "[34;1m"
            ]
        }
    }

    fileprivate var closingStylingDescriptor: String {
        get {
            return "[0m"
        }
    }

    fileprivate var allStylingDescriptors: [String] {
        get {
            var allDescriptors = openingStylingDescriptors
            allDescriptors.append(closingStylingDescriptor)
            return allDescriptors
        }
    }

    fileprivate var buildingString = ""

    var isBuilding: Bool {
        get {
            return buildingString != ""
        }
    }

    func add(_ character: Character) -> Bool {
        if !isBuilding {
            if character == "[" {
                buildingString.append(character)
                return true
            }

            return false
        }

        let stringAfterAdding = buildingString.appending(String(character))
        for descriptor in allStylingDescriptors {
            if descriptor.hasPrefix(stringAfterAdding) {
                buildingString = stringAfterAdding

                return true
            }
        }

        return false
    }

    func finish() -> (builtString: String, isValidStylingDescriptor: Bool) {
        var isValidStylingDescriptor = false
        for descriptor in allStylingDescriptors {
            if descriptor == buildingString {
                isValidStylingDescriptor = true
                break
            }
        }

        let builtString = buildingString
        buildingString = ""
        return (builtString, isValidStylingDescriptor)
    }
}
