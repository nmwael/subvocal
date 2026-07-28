# OBEY UI Patterns by ui-patterns.com

## When to use

Use when designing, reviewing, or refactoring user-facing screens and interactions that must be intuitive, reduce cognitive load, and follow proven recurring solutions. Applies to search, navigation, onboarding, data display, forms, and content layout in any mobile or web app.

## Primary bias to correct

Good UI is not invented from scratch for every feature. Recurring problems have proven solutions. Using established patterns gives users familiarity, reduces learning cost, and makes design decisions defensible. But patterns are not silver bullets -- they must be chosen by forces, not habit.

## Decision rules

### Search and input

- Use **Autocomplete** when users need recognition-aided search on data that is hard to remember or easily mistyped. Limit displayed matches to ~10, order by relevance, highlight matching text, and allow keyboard/touch selection. Do not use when the user needs an overview of all options.
- Use **Forgiving Format** when input can be entered in multiple valid forms (dates, phone numbers, card numbers). Parse and accept variations rather than forcing a single format.
- Use **Good Defaults** to pre-fill fields with the most likely value. Reduces effort, prevents errors, and sets expectations.
- Use **Input Feedback** to validate input in real time. Show success, error, or warning as the user types, not only on submit.
- Use **Autosave** to prevent data loss during long or interrupted form sessions. Communicate save state clearly.
- Use **Wizard** when a single goal requires multiple dependent sub-tasks that must be completed in sequence. Show progress, keep content above the fold, use plain language, summarize choices before final submission, and allow cancellation with clear warnings. Keep screen count low but do not cram too much into one step. Always provide an alternative to the wizard for experienced users.
- Use **Steps Left** to communicate how many steps remain in a process without the conditional branching of a Wizard.
- Use **Completeness Meter** to show how much of a multi-step form is filled. Motivates completion and reduces abandonment.

### Navigation

- Use **Navigation Tabs** for switching between a small number of peer views at the same hierarchy level.
- Use **Breadcrumbs** when the content hierarchy is deep and users need to understand where they are and jump back.
- Use **Cards** for browsing heterogeneous content (images + text + actions of varying length). Cards work best for discovery and browsing, not for strict search or homogeneous lists. One card = one concept. Use whitespace generously, limit content length, make the entire card clickable, and use rounded corners with subtle elevation. Do not use cards when content is uniform (use a list) or when strict ordering matters.
- Use **Progressive Disclosure** to reduce overwhelm. Show only the minimum data for the current task. Reveal complexity on demand via "Show more" or expandable sections. Ramp from simple to complex, abstract to specific.
- Use **Continuous Scrolling** (infinite scroll) for content streams where users browse and new content loads seamlessly. Pair with a loading indicator.
- Use **Pagination** when users need to locate specific items or when the total count matters.
- Use **Pull to Refresh** on mobile content lists to let users manually trigger a refresh with a natural gesture.

### Onboarding

- Use **Blank Slate** (Empty State) as the first screen when no content exists yet. Comfort, guide, and encourage. Answer: What is this? What do I do now? Show a sample of how the app will look with data. Set expectations to reduce frustration.
- Use **Coachmarks** to highlight specific UI elements and explain their purpose during first use.
- Use **Guided Tour** or **Walkthrough** for sequential introduction to key features. Do not overdo it -- keep tours short and skippable.
- Use **Lazy Registration** to let users experience core value before requiring account creation. Delay signup until the user is invested.
- Use **Inline Hints** to provide contextual help without leaving the current screen.

### Data display

- Use **Dashboard** when multiple data types must be displayed on one screen. Each card or widget is an entry point to deeper detail.
- Use **Gallery** for image collections where visual scanning is the primary interaction.
- Use **Table Filter** and **Sort By Column** when users need to find, compare, and order structured data.
- Use **FAQ** (Accordion) for content where users have specific questions and answers vary in length.

### Social and feedback

- Use **Activity Stream** to show a chronological feed of user or system actions.
- Use **Reaction** for lightweight, low-effort social feedback (like, heart, thumbs up).
- Use **Leaderboard** and **Achievements** when reputation and progress motivate continued engagement.

## Trigger rules

- When a user must search through a large or ambiguous dataset, reach for Autocomplete before a plain text field.
- When a form has more than 3-4 fields or dependent steps, consider Wizard or Progressive Disclosure instead of one long form.
- When the screen is empty and the user has no data yet, implement a Blank Slate with guidance and a clear primary action.
- When content consists of heterogeneous items with images, text, and varying length, use Cards instead of a uniform list.
- When the user is overwhelmed by options, apply Progressive Disclosure to hide advanced or rare features.
- When a feature is new to the user, add Coachmarks or Inline Hints rather than relying on documentation.
- When users need to see a lot of data at once, use Dashboard with Cards as entry points to detail.
- When a process has a fixed number of steps, use Steps Left to communicate progress and reduce anxiety.
- When the user might leave mid-task, add Autosave and communicate save state.
- When the user enters data in varying formats, use Forgiving Format rather than enforcing a single pattern.

## Final checklist

- Search uses Autocomplete with relevance ranking and a reasonable match limit?
- Complex forms split into steps (Wizard) with progress indication?
- Empty states handled with Blank Slate that guides and encourages?
- Heterogeneous content displayed as Cards with one concept per card?
- Advanced or rarely used options hidden behind Progressive Disclosure?
- Input validated in real time with Input Feedback?
- Onboarding uses Coachmarks or Guided Tour for new features, not walls of text?
- Navigation matches hierarchy depth (Tabs for peers, Breadcrumbs for deep paths)?
- Touch targets large enough and interactions forgiving of imprecise input?
- Each pattern chosen by the forces of the problem, not by default or habit?
