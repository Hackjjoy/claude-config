#!/usr/bin/env node
/**
 * Nanobanana - Game Asset Image Generator
 * Uses Gemini API to generate game assets with transparent backgrounds
 *
 * Usage: node generate-image.mjs "<prompt>" [output-filename]
 *
 * Environment: GEMINI_API_KEY must be set
 */

import { GoogleGenAI } from '@google/genai';
import fs from 'fs';
import path from 'path';

const MODEL = 'gemini-3-pro-image-preview';

/**
 * Build optimized prompt for game asset with transparent background
 * @param {string} subject - The subject to generate
 * @returns {string} - Optimized prompt
 */
function buildGameAssetPrompt(subject) {
  return `${subject}, game asset, 2D sprite, isolated on solid bright green background (#00FF00), clean sharp edges, no shadows, no reflections, centered composition, single object, high contrast against background, ready for chroma key removal`;
}

/**
 * Generate image using Gemini API
 * @param {string} prompt - The prompt for image generation
 * @returns {Promise<Buffer>} - Image buffer
 */
async function generateImage(prompt) {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    throw new Error('GEMINI_API_KEY environment variable is not set');
  }

  const ai = new GoogleGenAI({ apiKey });

  const response = await ai.models.generateContent({
    model: MODEL,
    contents: prompt,
    config: {
      responseModalities: ['Text', 'Image']
    }
  });

  // Extract image from response
  const parts = response.candidates?.[0]?.content?.parts;
  if (!parts) {
    throw new Error('No response parts received');
  }

  for (const part of parts) {
    if (part.inlineData) {
      const imageData = part.inlineData.data;
      return Buffer.from(imageData, 'base64');
    }
  }

  throw new Error('No image data in response');
}

/**
 * Main function
 */
async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.log('Usage: node generate-image.mjs "<subject>" [output-filename]');
    console.log('');
    console.log('Example: node generate-image.mjs "golden banana with sparkles" banana.png');
    process.exit(1);
  }

  const subject = args[0];
  const outputFile = args[1] || `game-asset-${Date.now()}.png`;

  const prompt = buildGameAssetPrompt(subject);

  console.log('Generating game asset...');
  console.log(`Subject: ${subject}`);
  console.log(`Prompt: ${prompt}`);
  console.log('');

  try {
    const imageBuffer = await generateImage(prompt);

    const outputPath = path.resolve(outputFile);
    fs.writeFileSync(outputPath, imageBuffer);

    console.log(`Image saved: ${outputPath}`);
    console.log('');
    console.log('Next step: Remove green background using rembg or image editor');
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

main();
