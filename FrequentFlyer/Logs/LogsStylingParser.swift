import Foundation

class LogsStylingParser {
    fileprivate var stylingDescriptorBuilder: StylingDescriptorBuilder
    fileprivate var hasOpenStylingElement: Bool = false

    init() {
        stylingDescriptorBuilder = StylingDescriptorBuilder()
    }

    func stripStylingCoding(originalString: String) -> String {
        var strippedString = ""
        for character in originalString.characters {
            if stylingDescriptorBuilder.isBuilding {
                let didAddCharacter = stylingDescriptorBuilder.add(character)
                if didAddCharacter { continue }

                let (builtString, isStylingDescriptor) = stylingDescriptorBuilder.finish()
                if !isStylingDescriptor {
                    strippedString.append(builtString)
                }

                let didStartNewDescriptor = stylingDescriptorBuilder.add(character)
                if didStartNewDescriptor { continue }
                strippedString.append(character)
            } else {
                let didStartBuilding = stylingDescriptorBuilder.add(character)
                if !didStartBuilding {
                    strippedString.append(character)
                }
            }
        }

        return strippedString
    }
}
