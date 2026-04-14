//
//  MindsetPrompt.swift
//  Domain
//

public enum MindsetPrompt: String, Prompt, Codable, CaseIterable, Hashable, Sendable {

    public var id: String { rawValue }

    case gratitude          // The Classic Morning 3
    case todoToday          // Morning Priorities
    case feel               // Morning Intention
    case gratitudeDeepDive  // NEW: What/Why/Who (Depth over Breadth)
    case subtracterWhat     // NEW: Loss Aversion (Objects/Resources)
    case subtracterWho      // NEW: Loss Aversion (People)
    case eveningWins        // NEW: The "Peak-End" Review (3 Wins)
    case silverLining       // NEW: Cognitive Reframing
    case sensorySnapshot   // Evening: Grounding
    case gratitudeMessage   // Monthly/Deep: Social Connection
    case kindness
    case savoring
    case bestPossibleSelf
    case signatureStrength
    case mementoMori
    case gratitude01
    case stoic
    case futureSelf
    
    public var headline: String {
        switch self {
        case .sensorySnapshot: 
            return "The Sensory Snapshot"
        case .gratitudeMessage: 
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
        case .kindness:
            return "The Kindness Booster"
        case .savoring:
            return "Present-Moment Savoring"
        case .bestPossibleSelf:
            return "The Optimism Bridge"
        case .signatureStrength:
            return "Strength Deployment"
        case .mementoMori:
            return "The Perspective Reset"
        case .gratitude01:
            return "The Gratitude Scan"
        case .stoic:
            return "The Circle of Control"
        case .futureSelf:
            return "The Intention Bridge"
        }
    }

    public var questionText: String {
        switch self {
        case .sensorySnapshot:
            return "Quiet the noise. What did your senses notice today?"
        case .gratitudeMessage:
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
        case .kindness:
            return "What is one small, unexpected act of kindness you could perform for someone today?"
        case .savoring:
            return "Identify one positive experience happening 'right now'. How can you intensify the joy of it?"
        case .bestPossibleSelf:
            return "Imagine yourself 5 years from now where everything has gone as well as possible. What is that version of you doing today?"
        case .signatureStrength:
            return "Which of your core strengths (e.g., Curiosity, Bravery, Humor) can you use in a 'new way' today?"
        case .mementoMori:
            return "If this were the final week of your life, what would you stop worrying about immediately?"
        case .gratitude01:
            return "What are three small things that went well in the last 24 hours?"
        case .stoic:
            return "What is one thing you are currently worried about that is actually outside of your control?"
        case .futureSelf:
            return "If you could only accomplish one thing today to feel proud of yourself, what would it be?"
        }
    }

    public var coachTip: String {
        switch self {
        case .sensorySnapshot:
            return "This isn't about grand events. The goal is 'micro-awareness'—the texture of your coffee cup or the rhythm of the rain."
        case .gratitudeMessage:
            return "You don't *have* to send this right now, but writing it as if they are reading it makes the emotional boost 10x stronger."
        case .gratitude:
            return "Name the feeling each one evokes — warmth, relief, joy — not just the object."
        case .todoToday:
            return "Be specific enough that you'd know if each item were done by tonight."
        case .feel:
            return "Link one concrete action to the emotional state you want."
        case .kindness:
            return "Research shows that 'clumping' five acts into one day creates a much higher happiness spike than spreading them out."
        case .savoring:
            return "Try 'behavioral expression'—smile, take a deep breath, or tell someone nearby how much you're enjoying this."
        case .bestPossibleSelf:
            return "Don't worry about the 'how' yet. Focus on the feeling of self-efficacy and reaching your goals."
        case .signatureStrength:
            return "Pick one strength and apply it to a task you usually find boring or difficult."
        case .gratitude01:
            return "Specificity is key. Instead of 'family', think 'the way my son laughed at breakfast'."
        case .futureSelf:
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
        case .kindness:
            return "The 'Secret Sauce' of kindness is anonymity. Try to do it without the other person knowing it was you for an extra dopamine boost."
        case .savoring:
            return "Savoring is 'Mindfulness with a Smile.' Don't just notice the moment; linger in it like you’re trying to memorize a melody."
        case .mementoMori:
            return "Use the 'End of Life' lens to filter out the 'Small Stuff.' If it won't matter in a year, don't give it more than a minute of worry today."
        case .stoic:
            return "Draw a line in the sand. On one side is your effort (Control); on the other is the outcome (External). Stay on your side of the line."
        default:
            return "Take a deep breath. There are no wrong answers here—only honest ones."
        }
    }

    public var scientificRationale: String {
        switch self {
        case .sensorySnapshot:
            return "Sensory grounding reduces ruminative 'brain chatter' and lowers evening cortisol."
        case .gratitudeMessage:
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
        case .kindness:
            return "Activates the pro-social happiness pathway (Lyubomirsky, 2005)."
        case .savoring:
            return "Strengthens the ability to extract pleasure from everyday experiences (Bryant & Veroff)."
        case .bestPossibleSelf:
            return "Linked to significant increases in optimism and health (King, 2001)."
        case .signatureStrength:
            return "Using signature strengths in new ways is proven to boost happiness for up to 6 months (Seligman)."
        case .mementoMori:
            return "Reduces anxiety over trivialities and clarifies life values."
        case .gratitude01:
            return "Scanning for the positive rewires the brain's default mode network."
        case .stoic:
            return "Reduces anxiety by narrowing focus to self-agency."
        case .futureSelf:
            return "Increases self-efficacy and goal attainment through mental contrasting."
        }
    }

    public var responseSlotCount: Int {
        slots.count
    }

    public var category: PromptCategory {
        switch self {
        case .gratitude, .gratitude01, .gratitudeDeepDive, .eveningWins, .silverLining, .subtracterWho, .subtracterWhat, .gratitudeMessage:
            return .gratitude
        case .todoToday, .feel, .futureSelf:
            return .futureSelf
        case .kindness:
            return .kindness
        case .savoring, .sensorySnapshot:
            return .savoring
        case .bestPossibleSelf:
            return .bestPossibleSelf
        case .signatureStrength:
            return .signatureStrength
        case .mementoMori:
            return .mementoMori
        case .stoic:
            return .stoic
        }
    }

    public var isMorningTemplate: Bool {
        switch self {
        case .gratitude, .todoToday, .feel, .gratitudeDeepDive:
            return true
        case .sensorySnapshot, .eveningWins, .silverLining:
            return false // Evening vibe
        default:
            return true // Default to morning for variety
        }
    }

    /// This is the "Engine" that drives the MultiSlotPromptQuestionView
    public var slots: [SlotMetadata] {
        switch self {
        case .sensorySnapshot:
            return [
                SlotMetadata(label: "SIGHT", placeholder: "Something beautiful you saw...", xpPoints: 10),
                SlotMetadata(label: "SOUND", placeholder: "A pleasing sound or song...", xpPoints: 10),
                SlotMetadata(label: "TOUCH", placeholder: "A comfort (e.g., cool air, soft bed)...", xpPoints: 10)
            ]
        case .gratitudeMessage:
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
        case .gratitude, .todoToday, .feel, .futureSelf, .bestPossibleSelf, .subtracterWhat, .subtracterWho:
            return .morning
            
            // Evening Rituals
        case .eveningWins, .sensorySnapshot, .silverLining, .mementoMori, .gratitude01:
            return .evening
            
            // Deep/Monthly Work
        case .gratitudeMessage, .gratitudeDeepDive, .signatureStrength:
            return .deepWork
            
            // Anytime / General
        case .kindness, .savoring, .stoic:
            return .anytime
        }
    }
}
