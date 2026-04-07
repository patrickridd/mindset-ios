//
//  PromptLibrary.swift
//  Domain
//

public enum PromptLibrary: String, Prompt, Codable, CaseIterable, Hashable, Sendable {

    public var id: String { rawValue }

    case gratitude          // The Classic Morning 3
    case todoToday          // Morning Priorities
    case feel               // Morning Intention
    case gratitudeDeepDive  // NEW: What/Why/Who (Depth over Breadth)
    case subtracterWhat     // NEW: Loss Aversion (Objects/Resources)
    case subtracterWho      // NEW: Loss Aversion (People)
    case eveningWins        // NEW: The "Peak-End" Review (3 Wins)
    case silverLining       // NEW: Cognitive Reframing
    case sensorySnapshot01   // Evening: Grounding
    case gratitudeMessage01   // Monthly/Deep: Social Connection
    case kindness01
    case savoring01
    case bestPossibleSelf01
    case signatureStrength01
    case mementoMori01
    case gratitude01
    case stoic01
    case futureSelf01
    
    public var headline: String {
        switch self {
        case .sensorySnapshot01: 
            return "The Sensory Snapshot"
        case .gratitudeMessage01: 
            return "The Gratitude Message"
        case .gratitude:
            return "Morning Gratitude"
        case .gratitudeDeepDive: 
            return "The Deep Dive"
        case .subtracterWhat:   
            return "The Perspective Shift"
        case .subtracterWho:   
            return "The Connection Reset"
        case .eveningWins:      
            return "Evening Victory Lap"
        case .silverLining:
            return "The Silver Lining"
        case .todoToday:
            return "Today's priorities"
        case .feel:
            return "Today's intention"
        case .kindness01:
            return "The Kindness Booster"
        case .savoring01:
            return "Present-Moment Savoring"
        case .bestPossibleSelf01:
            return "The Optimism Bridge"
        case .signatureStrength01:
            return "Strength Deployment"
        case .mementoMori01:
            return "The Perspective Reset"
        case .gratitude01:
            return "The Gratitude Scan"
        case .stoic01:
            return "The Circle of Control"
        case .futureSelf01:
            return "The Intention Bridge"
        }
    }

    public var questionText: String {
        switch self {
        case .sensorySnapshot01:
            return "Quiet the noise. What did your senses notice today?"
        case .gratitudeMessage01:
            return "Think of someone who has made a positive impact on your life."
        case .gratitudeDeepDive:
            return "Focus on one positive thing and explore its roots."
        case .subtracterWhat:   
            return "Think of something you use everyday that you could be grateful for."
        case .subtracterWho:    
            return "Think of a person who you could be grateful for."
        case .eveningWins:     
            return "What were 3 small wins from your day?"
        case .silverLining:     
            return "Reframe a moment of friction from today."
        case .gratitude:
            return "What are 3 things that make you 'feel' grateful?"
        case .todoToday:
            return "What are your top 3 things to get done today?"
        case .feel:
            return "How do you want to feel today and how could you accomplish that?"
        case .kindness01:
            return "What is one small, unexpected act of kindness you could perform for someone today?"
        case .savoring01:
            return "Identify one positive experience happening 'right now'. How can you intensify the joy of it?"
        case .bestPossibleSelf01:
            return "Imagine yourself 5 years from now where everything has gone as well as possible. What is that version of you doing today?"
        case .signatureStrength01:
            return "Which of your core strengths (e.g., Curiosity, Bravery, Humor) can you use in a 'new way' today?"
        case .mementoMori01:
            return "If this were the final week of your life, what would you stop worrying about immediately?"
        case .gratitude01:
            return "What are three small things that went well in the last 24 hours?"
        case .stoic01:
            return "What is one thing you are currently worried about that is actually outside of your control?"
        case .futureSelf01:
            return "If you could only accomplish one thing today to feel proud of yourself, what would it be?"
        }
    }

    public var coachTip: String {
        switch self {
        case .sensorySnapshot01:
            return "This isn't about grand events. The goal is 'micro-awareness'—the texture of your coffee cup or the rhythm of the rain."
        case .gratitudeMessage01:
            return "You don't *have* to send this right now, but writing it as if they are reading it makes the emotional boost 10x stronger."
        case .gratitude:
            return "Name the feeling each one evokes — warmth, relief, joy — not just the object."
        case .todoToday:
            return "Be specific enough that you'd know if each item were done by tonight."
        case .feel:
            return "Link one concrete action to the emotional state you want."
        case .kindness01:
            return "Research shows that 'clumping' five acts into one day creates a much higher happiness spike than spreading them out."
        case .savoring01:
            return "Try 'behavioral expression'—smile, take a deep breath, or tell someone nearby how much you're enjoying this."
        case .bestPossibleSelf01:
            return "Don't worry about the 'how' yet. Focus on the feeling of self-efficacy and reaching your goals."
        case .signatureStrength01:
            return "Pick one strength and apply it to a task you usually find boring or difficult."
        case .gratitude01:
            return "Specificity is key. Instead of 'family', think 'the way my son laughed at breakfast'."
        case .futureSelf01:
            return "Choose the 'frog'—the task you're most likely to procrastinate on."
        case .gratitudeDeepDive:
            return "Think of this as a 'Slow-Mo' replay. Focusing on the 'Why' and 'Who' turns a fleeting thought into a lasting neural pathway."
        case .subtracterWhat:
            return "Imagine your morning without your coffee maker or your car. It’s not about losing things; it’s about rediscovering their value."
        case .subtracterWho:
            return "Picture your life if you had never met this person. Notice the 'missing pieces'—those are the specific gifts they bring to your world."
        case .eveningWins:
            return "Size doesn't matter here. Answering a difficult email or choosing a healthy snack counts as a win. End your day on a high note."
        case .silverLining:
            return "This is the 'Aikido' of mindset. You’re not ignoring the friction; you’re using its energy to find a hidden lesson or a pivot point."
        case .kindness01:
            return "The 'Secret Sauce' of kindness is anonymity. Try to do it without the other person knowing it was you for an extra dopamine boost."
        case .savoring01:
            return "Savoring is 'Mindfulness with a Smile.' Don't just notice the moment; linger in it like you’re trying to memorize a melody."
        case .mementoMori01:
            return "Use the 'End of Life' lens to filter out the 'Small Stuff.' If it won't matter in a year, don't give it more than a minute of worry today."
        case .stoic01:
            return "Draw a line in the sand. On one side is your effort (Control); on the other is the outcome (External). Stay on your side of the line."
        default:
            return "Take a deep breath. There are no wrong answers here—only honest ones."
        }
    }

    public var scientificRationale: String {
        switch self {
        case .sensorySnapshot01:
            return "Sensory grounding reduces ruminative 'brain chatter' and lowers evening cortisol."
        case .gratitudeMessage01:
            return "The 'Gratitude Visit' exercise is the single most powerful intervention for increasing happiness (Seligman, 2005)."
        case .gratitudeDeepDive:
            return "Elaborative processing increases the neural impact of gratitude (Greater Good Science Center)."
        case .subtracterWhat, .subtracterWho:
            return "Mental subtraction combats hedonic adaptation by simulating loss (Koo et al., 2008)."
        case .eveningWins:
            return "Capitalizing on positive events at night improves sleep quality and reduces stress."
        case .silverLining:
            return "Cognitive reappraisal builds resilience and lowers cortisol levels."
        case .gratitude:
            return "Affect-focused gratitude strengthens emotional granularity and well-being."
        case .todoToday:
            return "Clear daily intentions improve follow-through and reduce cognitive load."
        case .feel:
            return "Aligning behavior with desired affect supports self-regulation and mood."
        case .kindness01:
            return "Activates the pro-social happiness pathway (Lyubomirsky, 2005)."
        case .savoring01:
            return "Strengthens the ability to extract pleasure from everyday experiences (Bryant & Veroff)."
        case .bestPossibleSelf01:
            return "Linked to significant increases in optimism and health (King, 2001)."
        case .signatureStrength01:
            return "Using signature strengths in new ways is proven to boost happiness for up to 6 months (Seligman)."
        case .mementoMori01:
            return "Reduces anxiety over trivialities and clarifies life values."
        case .gratitude01:
            return "Scanning for the positive rewires the brain's default mode network."
        case .stoic01:
            return "Reduces anxiety by narrowing focus to self-agency."
        case .futureSelf01:
            return "Increases self-efficacy and goal attainment through mental contrasting."
        }
    }

    public var responseSlotCount: Int {
        slots.count
    }

    public var category: PromptCategory {
        switch self {
        case .gratitude, .gratitude01, .gratitudeDeepDive, .eveningWins, .silverLining, .subtracterWho, .subtracterWhat, .gratitudeMessage01:
            return .gratitude
        case .todoToday, .feel, .futureSelf01:
            return .futureSelf
        case .kindness01:
            return .kindness
        case .savoring01, .sensorySnapshot01:
            return .savoring
        case .bestPossibleSelf01:
            return .bestPossibleSelf
        case .signatureStrength01:
            return .signatureStrength
        case .mementoMori01:
            return .mementoMori
        case .stoic01:
            return .stoic
        }
    }

    public var isMorningTemplate: Bool {
        switch self {
        case .gratitude, .todoToday, .feel, .gratitudeDeepDive:
            return true
        case .sensorySnapshot01, .eveningWins, .silverLining:
            return false // Evening vibe
        default:
            return true // Default to morning for variety
        }
    }

    /// This is the "Engine" that drives the MultiSlotPromptQuestionView
    public var slots: [SlotMetadata] {
        switch self {
        case .sensorySnapshot01:
            return [
                SlotMetadata(label: "SIGHT", placeholder: "Something beautiful you saw...", xpPoints: 10),
                SlotMetadata(label: "SOUND", placeholder: "A pleasing sound or song...", xpPoints: 10),
                SlotMetadata(label: "TOUCH", placeholder: "A comfort (e.g., cool air, soft bed)...", xpPoints: 10)
            ]
        case .gratitudeMessage01:
            return [
                SlotMetadata(label: "WHO", placeholder: "Their name...", xpPoints: 5),
                SlotMetadata(label: "THE IMPACT", placeholder: "What did they do for you?", xpPoints: 20),
                SlotMetadata(label: "MESSAGE", placeholder: "Draft a 2-sentence note to them...", xpPoints: 30)
            ]
        case .gratitude, .eveningWins, .todoToday:
            return [
                SlotMetadata(label: "FIRST", placeholder: "Identify the first item...", xpPoints: 10),
                SlotMetadata(label: "SECOND", placeholder: "Next one...", xpPoints: 10),
                SlotMetadata(label: "THIRD", placeholder: "Final one...", xpPoints: 15)
            ]
        case .gratitudeDeepDive:
            return [
                SlotMetadata(label: "WHAT", placeholder: "What happened?", xpPoints: 10),
                SlotMetadata(label: "WHY", placeholder: "Why did it matter?", xpPoints: 20),
                SlotMetadata(label: "WHO", placeholder: "Who is responsible for this?", xpPoints: 15)
            ]
        case .subtracterWhat, .subtracterWho:
            let target = self == .subtracterWhat ? "this resource" : "this person"
            return [
                SlotMetadata(label: "RECOGNIZE", placeholder: "Name them/it...", xpPoints: 5),
                SlotMetadata(label: "SUBTRACT", placeholder: "Imagine your day without \(target)...", xpPoints: 30)
            ]
        case .silverLining:
            return [
                SlotMetadata(label: "FRICTION", placeholder: "What went wrong?", xpPoints: 5),
                SlotMetadata(label: "THE GIFT", placeholder: "What is a hidden benefit or lesson?", xpPoints: 30)
            ]
        default:
            return [SlotMetadata(label: "ENTRY", placeholder: "Type your reflection...", xpPoints: 20)]
        }
    }

    public var type: PromptType {
        switch self {
            // Morning Rituals
        case .gratitude, .todoToday, .feel, .futureSelf01, .bestPossibleSelf01, .subtracterWhat, .subtracterWho:
            return .morning
            
            // Evening Rituals
        case .eveningWins, .sensorySnapshot01, .silverLining, .mementoMori01, .gratitude01:
            return .evening
            
            // Deep/Monthly Work
        case .gratitudeMessage01, .gratitudeDeepDive, .signatureStrength01:
            return .deepWork
            
            // Anytime / General
        case .kindness01, .savoring01, .stoic01:
            return .anytime
        }
    }
}
