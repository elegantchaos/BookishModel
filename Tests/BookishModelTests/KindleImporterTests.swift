// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 04/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import CoreData
import Actions

@testable import BookishModel

class KindleImporterTests: ModelTestCase {
    func testImport() {
        tagProcessorChannel.enabled = true
        
        let manager = ImportManager()
        let importer = KindleImporter(manager: manager)
        let container = makeTestContainer()

        let expectation = self.expectation(description: "import done")
        let bundle = Bundle(for: type(of: self))
        let xmlURL = bundle.url(forResource: "Kindle", withExtension: "xml")!
        importer.run(importing: xmlURL, in: container.managedObjectContext) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
        
        let books: [Book] = container.managedObjectContext.everyEntity(sorting: [NSSortDescriptor(key: "name", ascending: true)])
        XCTAssertEqual(books.count, 177)
        let titles = books.map { $0.name! }
        
        let expected = [
            "'NetWalkers 3: NeXus",
            "'NetWalkers Book 2: WildCards",
            "'NetWalkers Part One: Partners",
            "'NetWalkers Part Two: Of Mentors and Mimetrons",
            "A Big Ship at the Edge of the Universe (The Salvagers Book 1)",
            "A Book of Death and Fish",
            "A Closed and Common Orbit: Wayfarers 2",
            "A Dance With Dragons: Part 1 Dreams and Dust (A Song of Ice and Fire, Book 5)",
            "A Dance With Dragons: Part 2 After The Feast (A Song of Ice and Fire, Book 5)",
            "A Feast for Crows (A Song of Ice and Fire, Book 4)",
            "AMPED (Wired Book 2)",
            "Absorption (Ragnarok Book 1)",
            "Accelerando",
            "Accounts Demystified: The Astonishingly Simple Guide To Accounting",
            "Acts of the Apostles: Mind over Matter: Volume Blue",
            "All Systems Red (Kindle Single): The Murderbot Diaries",
            "Ancillary Justice: THE HUGO, NEBULA AND ARTHUR C. CLARKE AWARD WINNER (Imperial Radch Book 1)",
            "Ancillary Mercy: The conclusion to the trilogy that began with ANCILLARY JUSTICE (Imperial Radch Book 3)",
            "Ancillary Sword: SEQUEL TO THE HUGO, NEBULA AND ARTHUR C. CLARKE AWARD-WINNING ANCILLARY JUSTICE (Imperial Radch Book 2)",
            "Any Other Name (The Split Worlds Book 2)",
            "Archangel Down: Archangel Project. Book One",
            "Arrival",
            "Artificial Condition: The Murderbot Diaries",
            "Ascension Point (The Unity Sequence Book 1)",
            "Assassin’s Quest: Keystone. Gate. Crossroads. Catalyst. (The Farseer Trilogy, Book 3)",
            "Bad Metal 02: Dirty Jobs",
            "Becoming a Technical Leader",
            "Behind the Throne: The Indranan War, Book 1",
            "Between Two Thorns (The Split Worlds Book 1)",
            "Black Swan Rising (Black Swan Rising Trilogy Series Book 1)",
            "Caliban's War: Book 2 of the Expanse (now a Prime Original series)",
            "Changer (KESTREL Book 1)",
            "Command Decision: Vatta's War: Book Four",
            "Confederation (In Her Name, Book 5)",
            "Constitution: Book 1 of The Legacy Fleet Series",
            "Containment",
            "Contractor (The Contractors Book 1)",
            "Dark Space",
            "Date Night on Union Station (EarthCent Ambassador Book 1)",
            "Dead Soul (In Her Name, Book 3)",
            "Dead Souls (Inspector Rebus Book 10)",
            "Deception Well (The Nanotech Succession Book 2)",
            "Declare: SHORTLISTED FOR THE 2011 ARTHUR C. CLARKE AWARD",
            "Descent",
            "Déjà Vu (The Saskia Brandt Series Book One)",
            "Dreamer's Cat: A sci-fi murder mystery with a killer twist",
            "Duden Dictionary test",
            "Dust World (Undying Mercenaries Series Book 2)",
            "Dying For Space: Sunblinded Two (Sunblinded Trilogy Book 2)",
            "Elite: Reclamation (Elite: Dangerous)",
            "Embers of War",
            "Empire (In Her Name Book 4)",
            "Engaging The Enemy: Vatta's War: Book Three",
            "Entanglement",
            "Exiles: The Progenitor Trilogy, Book One",
            "Extreme Programming Explained: Embrace Change (XP Series)",
            "Final Battle (In Her Name, Book 6)",
            "First Contact (In Her Name, Book 1)",
            "Fleet of Knives: An Embers of War novel",
            "Forbidden The Stars (The Interstellar Age Book 1)",
            "Future Freaks",
            "Going Dark (The Red Trilogy Book 3)",
            "Gulliver's Travels",
            "Hero at Large: Second Edition (The Hunter Legacy Book 1)",
            "Hunted Hero Hunting: Second Edition (The Hunter Legacy Book 2)",
            "Jaggy Splinters",
            "Killing Titan (War Dogs Trilogy Book 2)",
            "Legend Of The Sword (In Her Name, Book 2)",
            "Leviathan Wakes: Book 1 of the Expanse (now a Prime Original series)",
            "Looking Through Lace",
            "Misfit Magic (Misfits Book 1)",
            "Moving Target: Vatta's War: Book Two",
            "Ninefox Gambit (Machineries of Empire Book 1)",
            "Old Man's War",
            "Oxford Dictionary of English",
            "Paper Promises: Money, Debt and the New World Order",
            "Peopleware: Productive Projects and Teams",
            "Places in the Darkness",
            "Provenance: A new novel set in the world of the Hugo, Nebula and Arthur C. Clarke Award-Winning ANCILLARY JUSTICE",
            "Reinventing Organizations: A Guide to Creating Organizations Inspired by the Next Stage of Human Consciousness",
            "Rook: Bridge & Sword: Awakenings (Bridge & Sword Series Book 1)",
            "Royal Assassin (The Farseer Trilogy, Book 2)",
            "Ruby Slippers",
            "Rule 34",
            "Running Out Of Space: Sunblinded One (Sunblinded Trilogy Book 1)",
            "Shield: Bridge & Sword: Awakenings (Bridge & Sword Series Book 2)",
            "Ship of Magic (The Liveship Traders, Book 1)",
            "Singularity Sky",
            "Something Coming Through",
            "Soul Identity",
            "Spinward Fringe Broadcast 0: Origins: A Collected Trilogy",
            "Spinward Fringe Broadcast 1 and 2: Resurrection and Awakening",
            "Spinward Fringe Broadcast 3: Triton",
            "Spinward Fringe Broadcast 4: Frontline",
            "Steel World (Undying Mercenaries Series Book 1)",
            "Take Back the Sky (War Dogs Trilogy 3)",
            "Team Geek: A Software Developer's Guide to Working Well with Others",
            "Tech-Heaven (The Nanotech Succession Book 0)",
            "Test-Driven iOS Development (Developer's Library)",
            "The Adventures of Sherlock Holmes",
            "The Age of Ra: Special Edition (Pantheon Book 1)",
            "The Apocalypse Codex: Book 4 in The Laundry Files",
            "The Atrocity Archives: Book 1 in The Laundry Files",
            "The Better Part of Valour: A Confederation Novel (Valour Confederation Book 2)",
            "The Bloodline Feud: The Family Trade and The Hidden Family (Merchant Princes Omnibus Book 1)",
            "The Bohr Maker (The Nanotech Succession Book 1)",
            "The Clan Corporate (Merchant Princes 3)",
            "The Cold Commands (A Land Fit for Heroes series Book 2)",
            "The Collapsing Empire (The Interdependency Book 1)",
            "The Corporation Wars: Dissidence",
            "The Corporation Wars: Insurgence",
            "The Dragon's Path: Book 1 of The Dagger and the Coin",
            "The Family Trade (Merchant Princes 1)",
            "The Fifth Season: The Broken Earth, Book 1, WINNER OF THE HUGO AWARD 2016 ",
            "The Fractal Prince (Jean le Flambeur Book 3)",
            "The Fuller Memorandum: Book 3 in The Laundry Files",
            "The Ghost Brigades (Old Man's War Book 2)",
            "The Girl Who Kicked the Hornets' Nest (Millennium Series Book 3)",
            "The Girl Who Played With Fire (Millennium Series Book 2)",
            "The Hanging Garden (Inspector Rebus Book 9)",
            "The Heart of Valour: A Confederation Novel (Valour Confederation Book 3)",
            "The Hidden Family (Merchant Princes)",
            "The Human Division (Old Man's War Book 5)",
            "The Hundred Thousand Kingdoms: Book 1 of the Inheritance Trilogy",
            "The Invisible Library (The Invisible Library series Book 1)",
            "The Jennifer Morgue: Book 2 in The Laundry Files",
            "The King's Blood: Book 2 of the Dagger and the Coin",
            "The Last Colony (Old Man's War Book 3)",
            "The Last Good Man",
            "The Liminal People: A Novel",
            "The Liminal War: a novel",
            "The Long Earth: (Long Earth 1)",
            "The Long Way to a Small, Angry Planet: Wayfarers 1",
            "The Mad Ship (The Liveship Traders, Book 2)",
            "The Name of the Wind: The Kingkiller Chronicle: Book 1 (Kingkiller Chonicles)",
            "The Necessary Death of Lewis Winter (The Glasgow Trilogy Book 1)",
            "The Neon Rain (Dave Robicheaux Book 1)",
            "The New Oxford American Dictionary",
            "The Noise Within",
            "The Non-Designer's Design Book: Non-Designers Design Bk_p3",
            "The Obelisk Gate: The Broken Earth, Book 2, WINNER OF THE HUGO AWARD 2017 (Broken Earth Trilogy)",
            "The Paper Samurai",
            "The Quantum Thief (Jean le Flambeur Book 1)",
            "The Red: First Light (The Red Trilogy Book 1)",
            "The Republic of Thieves: The Gentleman Bastard Sequence, Book Three (Gentleman Bastards 3)",
            "The Restoration Game",
            "The Revolution Trade: The Revolution Business and The Trade of Queens (Merchant Princes Omnibus Book 3)",
            "The Silver Metal Lover (Gateway Essentials Book 1)",
            "The Soldier (Rise of the Jain Book 1)",
            "The Sound of Shiant",
            "The Spider's War: Book Five of the Dagger and the Coin",
            "The Steel Remains (A Land Fit for Heroes series Book 1)",
            "The Synchronicity War Part 1",
            "The Three-Body Problem",
            "The Traders' War: The Clan Corporate and The Merchants' War (Merchant Princes Omnibus Book 2)",
            "The Trials (The Red Trilogy Book 2)",
            "The Truth of Valour: A Confederation Novel",
            "The Tyrant's Law: Book 3 of the Dagger and the Coin",
            "The Widow's House: Book 4 of the Dagger and the Coin",
            "The Wise Man's Fear: The Kingkiller Chronicle: Book 2 (Kingkiller Chonicles)",
            "Thin Air: From the author of Netflix's Altered Carbon (GOLLANCZ S.F.)",
            "This Is Not A Game: You Don't Get a Second Life",
            "Three Parts Dead (Craft Sequence Book 1)",
            "Too Like the Lightning (Terra Ignota Book 1)",
            "Trading In Danger: Vatta's War: Book One",
            "Transmission: Ragnarok: Book Two",
            "Two All - All For One",
            "Uprising (The Fall of Haven Book 1)",
            "Use Of Weapons (Culture series Book 3)",
            "Valour's Choice: A Confederation Novel (Valour Confederation Book 1)",
            "Valour's Trial: A Confederation Novel (Valour Confederation Book 4)",
            "Venus Rising (The Unity Sequence Book 2)",
            "Victory Conditions: Vatta's War: Book Five",
            "WIRED",
            "War Dogs (War Dogs Trilogy Book 1)",
            "Warstrider (Warstrider Series, Book One)",
            "When The Devil Drives (Jasmine Sharp Book 2)",
        ]


        if titles != expected {
            XCTFail("titles didn't match")
            print("let expected = [")
            for book in books {
                print("\t\"\(book.name!)\",")
            }
            print("]")
        }
    }

}
