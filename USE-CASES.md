# What EVIE is actually good for

Ranked. Not a wish list — an honest ordering of what returns time on day one versus what looks
impressive in a demo and disappoints in practice.

**How to read the ratings**

- **Viability** — how reliably this works right now, on a normal student laptop, without babysitting.
  ●●●●● works every time · ●●●○○ works with supervision · ●○○○○ demo-grade.
- **Impact** — how much workload it actually removes. Weighted toward *recurring* time, because a
  thing that saves 20 minutes every week beats a thing that saves two hours once.
- **Mode** — ☁ needs cloud (Claude), ⬛ works fine on the local model, ☁⬛ works in both with the
  local version being rougher.

The ranking is roughly viability × impact, with a thumb on the scale for how soon a student sees the
benefit. Something that pays off in week one gets used; something that pays off in week six doesn't.

---

## Tier 1 — Start here. These pay for the whole setup.

### 1. The single source of truth for what's due
**Viability ●●●●● · Impact ●●●●● · ☁⬛**

EVIE reads every subject folder, every daily note, and every brief you've dropped in, and produces
one ranked list of what's due and when. Then she keeps it current.

This sounds trivial. It is the highest-value thing in this document. The dominant source of student
stress is not difficulty — it's not knowing the shape of the week. Most students track deadlines
across a planner, three group chats, an LMS, and memory, and the cost of that fragmentation is
constant low-grade anxiety plus the occasional disaster.

> *"Read everything in my subject folders and give me one list of what's due in the next 14 days,
> hardest first. Flag anything I haven't started."*

Works perfectly on the local model. Set it up as a Routine that runs every Sunday.

---

### 2. Messy class notes → clean note + quiz questions
**Viability ●●●●● · Impact ●●●●● · ☁⬛**

You type or dictate whatever you caught in class. EVIE turns it into a structured note filed in the
right folder, flags what's obviously incomplete, and generates five recall questions from it.

The second half is what matters. Notes you never revisit are worth nothing, and the gap between
"took notes" and "made study material" is where most students quietly lose the term. This closes it
in ninety seconds instead of an hour.

Local model handles this well — it's summarising and reformatting, not reasoning.

---

### 3. Active recall drilling from your own notes
**Viability ●●●●● · Impact ●●●●● · ☁⬛**

*"Quiz me on Unit 3. One question at a time. Don't tell me the answer until I've tried. Track what I
get wrong."*

Testing yourself is the best-evidenced study technique there is, and almost nobody does it, because
making the questions is tedious and self-quizzing without a partner is awkward. EVIE removes both
obstacles, and — because the vault is persistent — she remembers what you missed last time and comes
back to it.

Talk mode is genuinely better than Chat here. Saying an answer out loud, badly, and being corrected
is closer to how an exam feels than typing it.

---

### 4. The explain-it-again loop
**Viability ●●●●● · Impact ●●●●○ · ☁ (⬛ workable)**

*"Explain covalent bonding. Now explain it like I'm twelve. Now with a different analogy. Now show me
where my version is wrong."*

The thing a class of forty cannot give you is the fifth explanation. A teacher explains it twice and
has to move on. EVIE will go ten rounds at 11pm without sighing.

Two rules make this work instead of feeling like cheating yourself: make her ask *you* to explain it
back, and make her show her work so you can catch her when she's wrong. On the local model she will
occasionally be confidently wrong about technical detail — verify anything that goes into an answer.

---

### 5. Assignment brief → project, broken into first steps
**Viability ●●●●○ · Impact ●●●●● · ☁⬛**

Paste or point her at the brief. She creates the project folder, extracts the actual requirements
and the rubric criteria into a checklist, works backward from the deadline to a schedule, and names
the specific first step you could do in the next twenty minutes.

The blank page is the enemy. "Write research paper" is not a task you can start; "list five possible
research questions and pick two" is. Converting the first into the second is the highest-leverage
thing EVIE does for procrastination.

---

### 6. Feedback on work you wrote
**Viability ●●●●● · Impact ●●●●○ · ☁ (⬛ weak)**

Not writing it. Reading it. Where's the argument thin, what does the rubric ask for that you haven't
addressed, which paragraph is doing no work, where did you say the same thing twice.

This is the line the guardrails draw, and it's the right line — a student who gets real feedback on
five drafts learns more than one who submits five generated essays and learns nothing. It's also the
version that survives a plagiarism check and a viva.

Cloud is meaningfully better here. Local-model critique tends toward generic advice.

---

### 7. File and download wrangling
**Viability ●●●●● · Impact ●●●○○ · ☁⬛**

*"Everything in my Downloads folder from this week that's a PDF — rename it to
`Subject - Topic - Date` and file it in the right subject folder."*

Unglamorous, works flawlessly, and quietly saves an hour a month. Also the safest possible first
task to try, because it's easy to verify she did it right.

This is where the deletion guardrail earns its keep. She'll move and rename all day; she stops and
asks before removing anything.

---

### 8. Weekly planning
**Viability ●●●●○ · Impact ●●●●○ · ☁⬛**

Sunday night: pull every deadline, look at what actually got done last week versus what was planned,
and build a realistic schedule around your actual free hours — not a fantasy one.

The value is in the second part. EVIE can see, from your daily notes, that you have planned four
hours of maths every Tuesday for a month and done it twice. Being told that by something that isn't
judging you is more useful than it sounds.

---

### 9. Citations, formatting, and the mechanical tail of an assignment
**Viability ●●●●○ · Impact ●●●●○ · ☁⬛**

Reformat a reference list into APA. Fix inconsistent heading levels. Build a table of contents.
Convert a messy table. Check the word count per section against the brief.

Pure friction removal on work that carries marks but teaches nothing. The one caution: she can format
a citation perfectly and still get the underlying details wrong. Check the details against the actual
source — always, on both models.

---

### 10. Checking maths and problem sets, with the working shown
**Viability ●●●○○ · Impact ●●●●○ · ☁**

You solve it, she checks it, and — the important part — she shows where your reasoning diverged
rather than just handing you the right number.

Rated three dots deliberately. Language models make arithmetic and algebra errors, and the local 9B
makes more of them. Use her to *locate* your error, not to certify your answer. If she disagrees with
you, that's a signal to look again, not proof you're wrong.

---

## Tier 2 — High value once the basics are habit

### 11. Research scaffolding
**Viability ●●●○○ · Impact ●●●●● · ☁ only**

Finding sources, summarising them, building a comparison table of what different papers claim,
tracking which of your points are actually supported.

Enormous when it works. Rated three because it needs live web access — dead on local — and because
**an unverified citation is a hazard, not a shortcut**. Every source she gives you gets opened and
checked before it goes in your paper. Build that into the habit from day one and this is a superpower;
skip it and it's an academic-integrity incident waiting to happen.

### 12. Long PDF digests
**Viability ●●●●○ · Impact ●●●●○ · ☁⬛**

Forty pages in, a structured summary and the five questions you should be able to answer out. Then
she quizzes you on it. Best combined with #3.

### 13. Group project coordination
**Viability ●●●●○ · Impact ●●●●○ · ☁⬛**

Meeting notes into a task list with names attached. Who owes what by when. A chase-up message
drafted for each person — that **you** then send, per the guardrail.

Underrated. Group work fails on coordination, not competence, and the coordinator role usually falls
to whoever cares most and burns them out.

### 14. Presentation outline and speaker notes
**Viability ●●●●○ · Impact ●●●○○ · ☁⬛**

Structure, slide-by-slide beats, speaker notes, and then she plays the audience and asks you the
three questions you're least ready for. That last part is the valuable one.

### 15. Lab and field data cleanup
**Viability ●●●○○ · Impact ●●●●○ · ☁**

Messy spreadsheets into consistent ones. Unit conversions. Spotting the row where someone typed a
comma instead of a period. Basic charts.

Verify the numbers. Always. This is exactly the task where a plausible wrong answer is hardest to
notice.

### 16. Language practice and translation
**Viability ●●●●○ · Impact ●●●○○ · ☁⬛**

Conversation practice in Talk mode, vocabulary drills from your own material, translating a source
you need but can't read. Kokoro ships voices in several languages if you want the practice partner to
sound right.

### 17. Exam post-mortem → targeted practice
**Viability ●●●●○ · Impact ●●●●○ · ☁⬛**

After a returned test: log every wrong answer with *why* it was wrong — misread the question, didn't
know it, knew it and slipped. Over a term that error log becomes the most valuable file in the vault,
and EVIE builds practice sets from it.

Almost nobody does this. The ones who do improve fastest.

### 18. Rubric self-audit before submitting
**Viability ●●●●● · Impact ●●●○○ · ☁⬛**

Line-by-line against the rubric: does this draft actually address each criterion, and where. Catches
the "I forgot the reflection section" disaster reliably. Two minutes, real marks.

### 19. Code debugging and explanation (CS/ICT students)
**Viability ●●●●○ · Impact ●●●●○ · ☁⬛**

Reading errors, explaining what a line does, finding the bug. This is Claude Code's home turf, so it
works well — but the learning-integrity rule applies just as hard here as to an essay. Have her
explain, not write.

### 20. Applications and opportunity tracking
**Viability ●●●●○ · Impact ●●●○○ · ☁⬛**

Scholarships, internships, competitions: a tracked list with deadlines and requirements, a
maintained CV that grows as you tell her what you did, and drafts you edit into your own voice.

---

## Tier 3 — Real, but narrower or later

### 21. Launching programs and running local workflows
**Viability ●●●○○ · Impact ●●●○○ · ☁⬛**

She can open installed applications, run scripts, and chain small local automations — the thing that
makes people say "wait, it can do that?"

Rated three not because it fails but because it's fragile and rarely the bottleneck. Impressive in a
demo, occasionally genuinely useful (batch file conversions, opening a whole working set at once),
and the place where you most want the guardrails tight. Anything with an install step, a delete, or a
send stops and asks.

### 22. Viva and interview rehearsal
**Viability ●●●●○ · Impact ●●●○○ · ☁**

She reads your paper and interrogates you on it in Talk mode. Genuinely uncomfortable, genuinely
effective. Best used the day before.

### 23. Accessibility and input relief
**Viability ●●●●○ · Impact varies wildly · ☁⬛**

For a student with dyslexia, a repetitive strain injury, a visual impairment, or who simply thinks
better out loud, Talk mode isn't a novelty — it's the difference between engaging and not. Dictate
messy thoughts, hear notes read back, work without typing.

Impact is unrated because for most students it's a nice-to-have and for some it's the entire reason
this is worth installing.

### 24. Metacognition — what you actually didn't understand
**Viability ●●●○○ · Impact ●●●●○ · ☁**

*"Looking at my last month of notes and quiz results, what am I avoiding?"*

Slow-burn, needs a populated vault, and one of the few things here a student genuinely cannot do for
themselves — you can't see your own blind spot by definition. Not a week-one use case. Worth building
toward.

### 25. Personal admin
**Viability ●●●●○ · Impact ●●○○○ · ☁⬛**

Budget tracking, allowance, schedules, reminders. Works fine. Low ceiling. Listed because students
ask for it and it's a harmless way to build the daily habit.

---

## Tier 4 — Don't

- **Writing anything you'll submit.** Blocked by the guardrails, and correctly. It converts a
  time-saving tool into an integrity problem and a learning deficit at the same time.
- **Trusting a citation you haven't opened.** The single fastest way to turn this project into a
  disciplinary meeting.
- **Anything needing current information, on local mode.** No web access, fixed knowledge. She'll
  answer anyway. That's the danger.
- **Long autonomous chains on the local model.** Six-plus tool calls on a 9B is where it drifts.
  Split the task or switch to cloud.
- **Serious statistical analysis.** Use a real tool; have her help you drive it.
- **Anything you'd be uncomfortable explaining to your teacher.** If you'd hide it, that's the answer.

---

## The same list, for a business

The mapping is almost one-to-one — the workflows are identical, only the nouns change.

| Student use case | Business equivalent | Viability | Impact |
|---|---|---|---|
| Deadline consolidation | Commitment and deliverable tracking across clients | ●●●●● | ●●●●● |
| Class notes → clean note | Meeting notes → decisions and actions | ●●●●● | ●●●●● |
| Assignment brief → project | Client brief → scoped project with milestones | ●●●●○ | ●●●●● |
| Feedback on your draft | Review of proposals, quotes, and contracts before they go out | ●●●●○ | ●●●●● |
| File wrangling | Document filing, invoice sorting, naming conventions | ●●●●● | ●●●●○ |
| Citations and formatting | Templating quotes, reports, and recurring documents | ●●●●● | ●●●●○ |
| Weekly planning | Weekly review: what shipped, what slipped, what's at risk | ●●●●○ | ●●●●○ |
| Research scaffolding | Competitor and market research | ●●●○○ | ●●●●○ |
| Group coordination | Delegation tracking and follow-up drafting | ●●●●○ | ●●●●○ |
| Exam post-mortem | Post-project retrospective and lessons log | ●●●●○ | ●●●●○ |
| Quiz me | Onboarding and training material from your own procedures | ●●●●○ | ●●●●● |

**Two things change for business use:**

The learning-integrity guardrail is irrelevant — replace it in `GUARDRAILS.md` with whatever your
compliance and client-confidentiality rules actually are. Write them as hard rules, in your words.

And the send-confirmation guardrail becomes the most important one in the file. A student sending an
awkward message to a classmate is a bad afternoon. A business sending a wrong quote to a client is a
different category of problem. Do not relax that rule because it gets tedious. It gets tedious
precisely on the days it's protecting you.

**The strongest business case, in one line:** an assistant that has read every one of your standard
operating procedures and can be asked about them at 2am by a new hire — running entirely on your own
hardware, with nothing leaving the building.
