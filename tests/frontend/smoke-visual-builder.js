const path = require('path');
const { chromium } = require('playwright');

async function sectionHasText(page, selector, text) {
  const locator = page.locator(selector);
  if (!(await locator.isVisible())) {
    throw new Error(`Expected ${selector} to be visible`);
  }

  const content = await locator.textContent();
  if (!content.includes(text)) {
    throw new Error(`Expected ${selector} to contain ${text}`);
  }
}

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1366, height: 900 } });

  await page.goto(`file://${path.resolve('visual-builder/item-1-start-page.html')}`);

  if (!(await page.locator('.sp-role-message.role-requester').isVisible())) {
    throw new Error('Requester role message not visible by default');
  }

  await page.locator('.sp-nav label[for="sp-tab-new-request"]').click({ force: true });
  await sectionHasText(page, '#sp-view-new-request', 'New / Correction Request');

  const requiredCount = await page
    .locator('#sp-view-new-request input[required], #sp-view-new-request select[required], #sp-view-new-request textarea[required]')
    .count();
  if (requiredCount < 10) {
    throw new Error(`Expected required fields in requester form, got ${requiredCount}`);
  }

  await page.locator('.sp-roles label[for="sp-role-reviewer"]').click({ force: true });
  await page.locator('.sp-nav label[for="sp-tab-review"]').click({ force: true });
  await sectionHasText(page, '#sp-view-review', 'Reviewer Request Detail');
  await page.locator('label[for="sp-just-risk-5"]').click({ force: true });
  await sectionHasText(page, '.risk-adjust-5', '+5 Adjustment');
  await sectionHasText(page, '#sp-view-review', 'Accept');
  await sectionHasText(page, '#sp-view-review', 'Send Correction');

  await page.locator('.sp-roles label[for="sp-role-admin"]').click({ force: true });
  await page.locator('.sp-nav label[for="sp-tab-risk-rules"]').click({ force: true });
  await sectionHasText(page, '#sp-view-risk-rules', 'Admin Risk Rule Configuration');

  const weights = await page
    .locator('#sp-view-risk-rules input.sp-risk-weight')
    .evaluateAll((nodes) => nodes.map((node) => Number(node.value)));
  const total = weights.reduce((sum, value) => sum + value, 0);
  if (total !== 100) {
    throw new Error(`Expected risk weights to total 100, got ${total}`);
  }

  await sectionHasText(page, '#sp-view-risk-rules', 'Admin Risky Country List');
  await browser.close();

  console.log(`PASS Visual Builder smoke: requiredFields=${requiredCount}, riskWeightTotal=${total}`);
})().catch(async (error) => {
  console.error(error.message || error);
  process.exit(1);
});
