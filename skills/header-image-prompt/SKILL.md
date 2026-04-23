---
name: header-image-prompt
description: Generate an AI art prompt for a blog post or GitHub discussion header image. Interactive skill that reads the content, interviews the user about their vision, and produces a ready-to-use prompt for any AI image generation tool. Use when the user says "header image", "create a header", "generate art for my post", or similar.
---

# Header Image Prompt

Generate AI art prompts for blog post and GitHub discussion header images through an interactive interview process.

## Overview

This skill reads the content you're creating a header image for, interviews you about your vision, and produces a polished prompt you can paste directly into an AI image generation tool. The output prompt is tool-agnostic -- it works with Nano Banana, Midjourney, DALL-E, or whatever you're using today.

## When to Use

Use this skill when:

- You're about to publish a blog post and need header art
- You're writing a GitHub discussion and want a visual header
- You want an illustration-style image that captures the essence of your writing
- You have a reference photo you want to incorporate into the concept

## Output Specification

All prompts must target these constraints:

- **Aspect ratio:** 5:2 (five units wide, two units tall) -- this is the standard header format
- **Style default:** Illustration (unless the user requests otherwise)
- **Format:** A single prompt block the user can copy-paste into their image generation tool
- **No tool-specific syntax:** Write the prompt as a natural description, not in any tool's proprietary format

## Workflow

### Step 1: Read the content

Ask the user for the content they want a header image for. This could be:

- A file path to a markdown document
- A URL to a GitHub discussion or blog post
- Pasted text in the conversation

Read the full content. Identify:

- The core theme or argument
- Key metaphors or imagery already present in the writing
- The emotional tone (reflective, energetic, technical, personal)
- Any concrete objects, scenes, or concepts that could translate visually

### Step 2: Present your initial read

Share a brief summary (2-3 sentences) of what you took away from the content and what visual directions you're already thinking about. This gives the user a chance to correct course early before the interview goes deeper.

### Step 3: Interview the user

Ask questions to narrow down the visual direction. Do not ask all questions at once -- have a conversation, adapting based on their answers. Start with the most important questions and follow the thread.

**Opening questions (pick 1-2 to start):**

- What feeling do you want someone to get when they see this image before they start reading?
- Is there a specific scene, metaphor, or moment from the writing that you keep picturing?
- Are you drawn to something abstract and atmospheric, or something more literal and concrete?

**Follow-up questions (use as the conversation develops):**

- Color palette -- do you have a mood in mind? (warm, cool, muted, vibrant, monochrome)
- Should this feel playful, serious, contemplative, energetic?
- Any visual elements you definitely want included or excluded?
- Have you seen any header images recently that you liked? What about them worked?
- Should people appear in the image? If so, how prominent?

**Style clarification (if needed):**

- The default is illustration style. If you want something different (watercolor, line art, flat design, photorealistic, collage, pixel art), let me know.
- How detailed vs. minimal? Dense composition or lots of breathing room?

### Step 4: Ask about input images

If the user hasn't already mentioned a reference image, ask:

- Do you have a photo or image you'd like to use as a starting point or reference? Some ideas:
  - A photo of yourself to base an illustrated version on
  - A photo that captures the mood or setting you're going for
  - A sketch or rough concept you've drawn
  - A screenshot or diagram from the work itself

If they provide an image, incorporate it into the prompt as a reference description (since the user will need to upload it separately to their image generation tool). Describe how the reference image should influence the output -- as a pose reference, mood reference, composition reference, or style reference.

### Step 5: Generate the prompt

Synthesize everything from the interview into a single, well-crafted prompt. Structure it as:

1. **Subject and scene** -- What is depicted
2. **Style and medium** -- Illustration style, technique references
3. **Composition** -- How elements are arranged in the 5:2 frame (wide and short means careful thought about horizontal composition)
4. **Color and lighting** -- Palette and mood
5. **Atmosphere and detail level** -- The overall feeling

Present the prompt in a code block so it's easy to copy.

**Important considerations for 5:2 aspect ratio:**

- This is a very wide, short frame -- avoid tall subjects that would be cropped or tiny
- Think panoramic: landscapes, wide scenes, horizontal arrangements
- Subjects should be composed to work in this letterbox format
- Leave space on the sides -- the image often has text overlaid or sits above a title

### Step 6: Refine

After presenting the prompt, ask the user:

- Does this capture what you're going for?
- Anything you'd add, remove, or change?
- Want me to try a completely different direction?

Iterate until they're happy. When refining, present the full updated prompt each time (don't just describe the changes -- give them the complete copy-pasteable prompt).

## Tips for Quality Prompts

- Be specific about composition in the 5:2 frame -- "a wide panoramic view" or "subject positioned left of center with negative space on the right"
- Use concrete visual language, not abstract concepts -- "warm golden hour light filtering through trees" not "a feeling of warmth and nature"
- Reference specific illustration styles when helpful -- "in the style of editorial illustration" or "flat vector illustration with subtle gradients"
- For images based on reference photos, describe the transformation clearly -- "an illustrated portrait based on the reference photo, rendered in [style], maintaining the pose and expression but stylized with [details]"
- Keep prompts between 50-150 words -- long enough to be specific, short enough to not confuse the model

## Example Prompts

### Start a header image session

```
I need a header image for my latest blog post. Here's the file: Daily Projects/2026-02-13/01 writing with ai guide.md
```

### Quick with context

```
Generate a header image prompt for this discussion I'm about to publish. It's about our team's approach to DDoS mitigation over the past 5 years.
```

### With a reference image

```
I want a header image for my blog post about writing with AI. I have a photo of myself at my desk I'd like to use as a starting point.
```
