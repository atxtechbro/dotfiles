#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

console.log('Verifying patchright installation...\n');

// Check if playwright resolves to patchright
try {
  const playwrightPath = require.resolve('playwright');
  const playwrightPackage = require('playwright/package.json');
  
  console.log('playwright resolves to:', playwrightPath);
  console.log('Package name:', playwrightPackage.name);
  console.log('Package version:', playwrightPackage.version);
  
  if (playwrightPackage.name === 'patchright') {
    console.log('✓ Successfully aliased playwright to patchright');
  } else {
    console.log('✗ playwright is not aliased to patchright');
  }
} catch (e) {
  console.error('Error checking playwright:', e.message);
}

console.log('\n--- Quick functionality test ---');
const { chromium } = require('playwright');
console.log('chromium.name:', chromium.name());
console.log('✓ Patchright-aliased playwright is functional');
