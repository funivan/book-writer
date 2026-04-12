---
name: prepare-characters
description: Analyze original.txt and create structured character descriptions in characters.txt file.
---

# Prepare Characters

Analyze a story text and create structured descriptions for each character in a characters.txt file.

## When to Use

- Preparing character profiles before story generation
- Analyzing characters from source material
- Creating reference material for writing
- Triggered by: "prepare characters", "підготуй персонажів", "створи описи персонажів", "проаналізуй персонажів"

## Instructions

### Step 1: Read original.txt

Read `{source_folder}/original.txt` and identify all characters.

### Step 2: Analyze each character

For each character determine:
- Physical characteristics (if mentioned)
- Core personality and traits
- Behavior in different situations
- Interactions with other characters
- Emotional aspects and motivation

### Step 3: Create characters.txt

Create file `{source_folder}/characters.txt` in this format:

```
ОПИСИ ПЕРСОНАЖІВ

[CHARACTER NAME]:
[First sentence about character and main trait]. [Second sentence about behavior and features]. [Third sentence about interactions with others]. [Fourth sentence with specific examples from text]. [Fifth and sixth sentences about emotional aspects and character].

[NEXT CHARACTER]:
...
```

## Description Requirements

### Format

- Character name: UPPERCASE with colon `[NAME]:`
- Each description: 5-10 sentences in one paragraph
- Order: alphabetical by name (Ukrainian alphabet)

### Content

Each description must include:
1. Appearance (if mentioned in text)
2. Personality and traits
3. Typical behavior in different situations
4. Interactions with other characters
5. Emotions and motivation
6. Specific examples from text

## Style Guidelines

- **Language**: Ukrainian
- **Tone**: Objective, analytical
- **Focus**: Character behavior and traits
- **Evidence**: Use specific examples from the text

## Example Output

```
ОПИСИ ПЕРСОНАЖІВ

ЕНДІ:
Енді — один з головних героїв, який живе на дереві разом з Террі. Він відрізняється імпульсивністю та схильністю до авантюр. У складних ситуаціях часто діє перш ніж думає, що призводить до комічних непорозумінь. Попри хаотичну натуру, Енді щиро піклується про друзів. Він завжди готовий допомогти, навіть якщо його методи не завжди ефективні. Його оптимізм та енергія заряджають оточуючих.

ТЕРРІ:
Террі — найкращий друг Енді, більш розсудливий та обережний. Він часто виступає голосом розу|ому в парі. Террі любить винаходити та майструвати різні пристрої. Його винаходи не завжди працюють як задумано, але він ніколи не здається. У конфліктних ситуаціях намагається знайти компроміс. Цінує дружбу та лояльність понад усе.
```

## Important Notes

- **Read entire text** - characters may be revealed gradually
- **Cite the text** - descriptions must be based on specific examples
- **Don't invent** - if information isn't mentioned, don't add it
- **Alphabetical order** - sort characters by Ukrainian alphabet
