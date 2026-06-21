import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/assets.dart';
import '../domain/models.dart';
import 'nutritionist_repository.dart';
import 'tips_repository.dart';

/// Repository contract. The curated in-code source below can later be
/// swapped for a remote CMS / verified directory without touching UI code.
abstract interface class ContentRepository {
  List<SpecialistProfile> listSpecialists();
  List<Article> listArticles();
  Article? articleById(String id);
  SpecialistProfile? specialistById(String id);
}

/// Standard closing paragraph appended to every article body.
const String _disclaimer =
    'This content is educational and not a substitute for professional '
    'medical advice. If symptoms persist, consult a qualified healthcare '
    'professional.';

class CuratedContentRepository implements ContentRepository {
  const CuratedContentRepository();

  static const List<SpecialistProfile> _specialists = [
    SpecialistProfile(
      id: 'sp-1',
      name: 'Mariana Solano, RD',
      kind: SpecialistKind.nutritionist,
      headline:
          'Registered dietitian focused on digestive health. Helps people '
          'eat well with sensitive stomachs, without fear or fad diets.',
      bio: 'Mariana is a registered dietitian with a decade of experience '
          'supporting people who live with IBS, reflux and food '
          'intolerances. She believes nutrition advice should be practical, '
          'compassionate and grounded in evidence. Her work centers on '
          'helping people expand their diets safely rather than restricting '
          'them unnecessarily.',
      topics: ['Digestive health', 'IBS nutrition', 'Low-FODMAP', 'Meal planning'],
      imageAsset: AppAssets.defaultSpecialistPhoto,
    ),
    SpecialistProfile(
      id: 'sp-2',
      name: 'Dr. Andrés Okafor',
      kind: SpecialistKind.gastroenterologist,
      headline:
          'Gastroenterology educator translating gut science into plain '
          'language. Passionate about helping people understand their own '
          'digestion.',
      bio: 'Dr. Okafor has spent his career in clinical gastroenterology '
          'and medical education. He writes and teaches about common '
          'digestive conditions, focusing on what the evidence actually '
          'supports. He is a strong advocate for patient education as the '
          'first step toward better outcomes.',
      topics: ['Gut health', 'IBS', 'Microbiome', 'Digestive conditions'],
      imageAsset: AppAssets.defaultSpecialistPhoto,
    ),
    SpecialistProfile(
      id: 'sp-3',
      name: 'Lucía Fernández',
      kind: SpecialistKind.fitnessCoach,
      headline:
          'Fitness and nutrition coach who pairs gentle movement with '
          'sustainable eating habits. Believes consistency beats intensity.',
      bio: 'Lucía is a certified fitness and nutrition coach who works '
          'with everyday people, not athletes. Her approach combines '
          'realistic movement goals with simple food habits that survive '
          'busy weeks. She focuses on building routines that feel good in '
          'the body, including for those with digestive sensitivities.',
      topics: ['Healthy habits', 'Movement', 'Balanced eating', 'Routine building'],
      imageAsset: AppAssets.defaultSpecialistPhoto,
    ),
    SpecialistProfile(
      id: 'sp-4',
      name: 'Digestive Health Foundation',
      kind: SpecialistKind.institution,
      headline:
          'Independent educational organisation dedicated to digestive '
          'wellness. Publishes accessible, evidence-aligned guidance for '
          'the public.',
      bio: 'The Digestive Health Foundation curates and reviews '
          'educational material about digestion, nutrition and gut health. '
          'Its content is written for the general public and reviewed for '
          'accuracy against current scientific consensus. The foundation '
          'does not sell products or endorse specific diets.',
      topics: ['Digestive health', 'Public education', 'Gut health', 'Nutrition science'],
      imageAsset: AppAssets.defaultSpecialistPhoto,
      websiteUrl: 'https://www.who.int',
      verified: true,
    ),
    SpecialistProfile(
      id: 'sp-5',
      name: 'Tomás Aguilar',
      kind: SpecialistKind.creator,
      headline:
          'Recipe creator specialising in gut-friendly comfort food. '
          'Proves that gentle on the stomach can still taste amazing.',
      bio: 'Tomás develops recipes designed for sensitive digestion, from '
          'low-FODMAP weeknight dinners to lactose-free desserts. He works '
          'closely with dietitians to keep his recipes both delicious and '
          'sensible. His mission is simple: nobody should feel left out at '
          'the table.',
      topics: ['Gut-friendly recipes', 'Low-FODMAP cooking', 'Lactose-free'],
      imageAsset: AppAssets.defaultSpecialistPhoto,
    ),
  ];

  static const List<Article> _articles = [
    Article(
      id: 'art-1',
      title: 'Understanding IBS: an everyday guide',
      topic: ArticleTopic.ibs,
      summary:
          'What irritable bowel syndrome is, what it is not, and practical '
          'ways people manage day-to-day symptoms.',
      readMinutes: 5,
      authorId: 'sp-2',
      body: '''
Irritable bowel syndrome, or IBS, is one of the most common digestive conditions worldwide. It describes a pattern of recurring abdominal discomfort linked to changes in bowel habits, such as bloating, constipation, diarrhoea, or a mix of both. Importantly, IBS is a functional condition: standard tests usually come back normal, which can feel frustrating but also means the gut is not damaged.

Researchers describe IBS as a disorder of gut-brain interaction. The nerves connecting the digestive system and the brain can become extra sensitive, so normal digestion is felt more intensely. Stress, sleep, certain foods and hormonal changes can all influence how strongly symptoms show up on a given day.

Because triggers vary so much between people, there is no single "IBS diet". Many people find it helpful to keep a simple journal of meals, stress levels and symptoms for a few weeks. Patterns often emerge that are far more useful than generic food lists found online.

Common, low-risk strategies include eating at regular times, chewing slowly, staying hydrated, and moderating known irritants such as large amounts of caffeine, alcohol or very fatty meals. Gentle, regular movement like walking also supports normal gut motility for many people.

Structured dietary approaches, such as the low-FODMAP protocol, can help some people identify specific carbohydrate triggers. These work best with guidance from a registered dietitian, since the goal is always to return to the widest, most varied diet possible.

Living with IBS can be tiring, but most people find a combination of habits that meaningfully reduces symptoms over time. Be patient with the process and sceptical of anyone promising a quick universal cure.

$_disclaimer''',
    ),
    Article(
      id: 'art-2',
      title: 'A gentle introduction to the low-FODMAP approach',
      topic: ArticleTopic.ibs,
      summary:
          'The three phases of the low-FODMAP protocol explained simply, '
          'and why it is a learning tool rather than a forever diet.',
      readMinutes: 5,
      authorId: 'sp-1',
      body: '''
FODMAPs are a group of short-chain carbohydrates — fermentable oligosaccharides, disaccharides, monosaccharides and polyols — found in many everyday foods like wheat, onions, garlic, some fruits and dairy. In sensitive guts they can draw in water and ferment quickly, producing gas, bloating and discomfort.

The low-FODMAP approach was developed by researchers at Monash University and is one of the better-studied dietary strategies for IBS-type symptoms. It is not a weight-loss diet and it is not meant to be permanent.

The protocol has three phases. First comes a short elimination phase, usually two to six weeks, where high-FODMAP foods are swapped for lower-FODMAP alternatives. The goal here is simply to see whether symptoms calm down.

The second phase is reintroduction: FODMAP groups are tested one at a time, in increasing portions, while observing symptoms. This is the most valuable phase, because it reveals which specific groups and amounts are actually a problem — often far fewer than people expect.

The third phase is personalisation. Foods that were tolerated come back into regular rotation, and only genuine triggers are moderated. A varied diet matters for long-term gut health, so the aim is always the least restrictive diet that keeps symptoms manageable.

Because elimination diets carry nutritional and social costs, the approach works best with support from a registered dietitian. If that is not accessible, keep the elimination phase short and prioritise the reintroduction phase rather than staying restricted indefinitely.

$_disclaimer''',
    ),
    Article(
      id: 'art-3',
      title: 'Gut microbiome 101: why fiber matters',
      topic: ArticleTopic.gutHealth,
      summary:
          'Meet the trillions of microbes in your gut and learn why fiber '
          'is their favourite food — and yours.',
      readMinutes: 4,
      authorId: 'sp-2',
      body: '''
Your large intestine hosts trillions of microorganisms — bacteria, archaea, fungi and viruses — collectively known as the gut microbiome. Far from being passive passengers, these microbes help digest food, produce vitamins, train the immune system and communicate with the brain.

One of the clearest findings in nutrition science is that dietary fiber feeds these microbes. Fiber is the part of plant foods our own enzymes cannot break down, so it travels to the colon, where bacteria ferment it into short-chain fatty acids such as butyrate.

Short-chain fatty acids are remarkable molecules. They are the preferred fuel of the cells lining the colon, they help keep the gut barrier healthy, and they appear to have calming effects on inflammation throughout the body.

Diversity matters as much as quantity. Different fibers feed different microbes, so eating a wide variety of plants — vegetables, fruits, legumes, whole grains, nuts and seeds — tends to support a more diverse microbial community. Some researchers suggest aiming for many different plant foods across a week rather than fixating on any single "superfood".

Most adults eat considerably less fiber than guidelines recommend, which is typically around 25 to 38 grams per day. If your current intake is low, increase it gradually and drink enough water; a sudden jump can cause temporary gas and bloating while your microbiome adjusts.

Small swaps add up quickly: whole-grain bread instead of white, an extra serving of vegetables at dinner, fruit with breakfast, or a handful of legumes added to soups and salads.

$_disclaimer''',
    ),
    Article(
      id: 'art-4',
      title: 'Probiotics and fermented foods: what we actually know',
      topic: ArticleTopic.gutHealth,
      summary:
          'Separating evidence from marketing on yogurt, kefir, kimchi and '
          'probiotic supplements.',
      readMinutes: 5,
      authorId: 'sp-1',
      body: '''
Probiotics are live microorganisms that, when consumed in adequate amounts, may offer a health benefit. They are found in supplements and in some fermented foods such as yogurt with live cultures, kefir, kimchi, sauerkraut and certain aged cheeses.

It is worth knowing that "fermented" and "probiotic" are not the same thing. Many fermented foods are heat-treated after fermentation, which kills the live microbes, and not every surviving microbe has demonstrated benefits. That does not make these foods unhealthy — fermentation can still improve flavour, digestibility and nutrient availability.

The scientific picture on probiotics is genuinely mixed. Effects are strain-specific and condition-specific: a strain that helps with one issue may do nothing for another. Some strains have reasonable evidence for specific situations, such as supporting the gut during a course of antibiotics, while evidence for general "gut health" claims in healthy people is much weaker.

If you enjoy fermented foods, they fit comfortably into a balanced diet and may contribute to microbial exposure and dietary variety. Plain yogurt or kefir, for example, can also be easier to tolerate than milk for some people with lactose intolerance, because the cultures pre-digest part of the lactose.

If you are considering a supplement, be a careful consumer. Look for products that name their strains and doses, match the strain to the specific purpose studied, and give it a defined trial period rather than taking it indefinitely without noticing any difference.

Finally, remember that probiotics are guests, not gardeners. The everyday foundation of a resilient microbiome remains a varied, fiber-rich diet, regular sleep, movement and stress management.

$_disclaimer''',
    ),
    Article(
      id: 'art-5',
      title: 'Lactose intolerance vs. dairy allergy: knowing the difference',
      topic: ArticleTopic.intolerances,
      summary:
          'Two very different conditions that are often confused — and why '
          'the distinction changes what you can safely eat.',
      readMinutes: 4,
      body: '''
Lactose intolerance and dairy allergy are frequently mixed up, but they involve completely different systems in the body and call for different levels of caution.

Lactose intolerance is a digestive issue. It happens when the small intestine produces too little lactase, the enzyme that breaks down lactose, the natural sugar in milk. Undigested lactose travels to the colon, where bacteria ferment it, producing gas, bloating, cramps or diarrhoea. Uncomfortable, certainly, but not dangerous.

A dairy allergy, by contrast, is an immune reaction to milk proteins such as casein or whey. Reactions can include hives, swelling, vomiting or, in severe cases, anaphylaxis, which is a medical emergency. Milk allergy is most common in young children and requires strict avoidance under medical guidance.

The practical difference is important. Many people with lactose intolerance can still enjoy dairy in moderation: hard aged cheeses contain very little lactose, yogurt cultures pre-digest some of it, lactose-free milk is widely available, and lactase enzyme tablets can help with occasional indulgences. Tolerance is often a matter of dose rather than all-or-nothing.

Self-diagnosis can be misleading, because symptoms overlap with other conditions such as IBS. If dairy seems to bother you, it is worth discussing proper testing with a healthcare professional before permanently cutting out a whole food group, since dairy is a convenient source of calcium, protein and other nutrients.

If you do reduce dairy, plan replacements deliberately: fortified plant drinks, canned fish with bones, tofu set with calcium, and leafy greens can help cover calcium needs.

$_disclaimer''',
    ),
    Article(
      id: 'art-6',
      title: 'Gluten: who really needs to avoid it?',
      topic: ArticleTopic.intolerances,
      summary:
          'Coeliac disease, wheat allergy and non-coeliac sensitivity '
          'explained — and why testing before quitting gluten matters.',
      readMinutes: 5,
      authorId: 'sp-2',
      body: '''
Gluten is a family of proteins found in wheat, barley and rye. For most people it is harmless, yet gluten-free eating has become one of the most popular dietary trends. So who genuinely benefits from avoiding it?

The clearest case is coeliac disease, an autoimmune condition affecting roughly one percent of the population. In coeliac disease, gluten triggers an immune attack on the lining of the small intestine, which can cause digestive symptoms, nutrient deficiencies, fatigue and long-term complications. Treatment is a strict, lifelong gluten-free diet.

Wheat allergy is a separate immune reaction to wheat proteins, more common in children, with symptoms ranging from hives to breathing difficulty. It requires avoiding wheat specifically, under professional guidance, rather than all gluten grains.

A third group reports symptoms after eating gluten without having coeliac disease or wheat allergy — often called non-coeliac gluten sensitivity. Research here is still evolving; in some studies, other wheat components such as fructans (a FODMAP) explain symptoms better than gluten itself, which is why some people who "react to gluten" tolerate sourdough or low-FODMAP portions surprisingly well.

One point matters enormously: get tested before going gluten-free. Coeliac blood tests and biopsies only work reliably while you are still eating gluten, so quitting first can make an accurate diagnosis difficult and delay proper care.

For everyone else, there is no solid evidence that avoiding gluten improves health, and whole-grain wheat products contribute useful fiber and nutrients. Gluten-free substitutes are often more processed and more expensive, so the switch is not automatically the healthier choice.

$_disclaimer''',
    ),
    Article(
      id: 'art-7',
      title: 'Building a balanced plate without counting calories',
      topic: ArticleTopic.nutritionBasics,
      summary:
          'A simple visual method for assembling satisfying, balanced '
          'meals — no apps, scales or math required.',
      readMinutes: 4,
      authorId: 'sp-3',
      body: '''
Calorie counting works for some people, but for many it turns eating into homework and ignores what food is actually made of. The balanced plate method offers a simpler alternative: instead of numbers, you use the proportions on your plate as a guide.

Start by mentally dividing your plate. Around half goes to vegetables and fruits — the more colour and variety, the better. They bring fiber, vitamins, minerals and volume that helps you feel satisfied without needing huge portions of everything else.

About a quarter of the plate goes to protein: legumes, fish, eggs, poultry, tofu, dairy or lean meats. Protein digests slowly, helps maintain muscle and is one of the most reliable contributors to feeling full between meals.

The remaining quarter is for carbohydrates, ideally favouring whole or minimally processed options such as brown rice, potatoes, oats, corn, quinoa or whole-grain bread. These provide steady energy along with extra fiber for your gut microbes.

Round the plate out with a modest amount of healthy fats — olive oil, avocado, nuts, seeds — and water as the default drink. Fats add flavour and help absorb certain vitamins, so they belong on the plate, just in sensible amounts.

The beauty of this method is flexibility. It adapts to tacos, stir-fries, soups and shared dishes; you simply keep the rough proportions in mind. Some meals will not match the template, and that is fine — balance is something you build across days, not in any single meal.

$_disclaimer''',
    ),
    Article(
      id: 'art-8',
      title: 'Hydration and digestion: small habit, big impact',
      topic: ArticleTopic.habits,
      summary:
          'How water supports every stage of digestion, and easy ways to '
          'drink enough without forcing it.',
      readMinutes: 3,
      authorId: 'sp-3',
      body: '''
Water is involved in nearly every step of digestion. Saliva begins breaking down food in the mouth, stomach secretions continue the job, and the intestines rely on fluid to move contents along smoothly. When you are short on fluids, the colon reclaims more water from waste, which is one reason mild dehydration is linked with harder stools and constipation.

Hydration also works hand in hand with fiber. Fiber absorbs water to keep things soft and moving, so increasing fiber without increasing fluids can actually backfire and cause discomfort. The two habits belong together.

How much is enough? Needs vary with body size, climate and activity, so rigid rules are less useful than a simple check: pale-yellow urine generally suggests you are drinking enough, while dark urine suggests you could use more. Thirst is also a reasonable guide for most healthy adults.

Plain water is ideal, but it is not the only source. Soups, fruits, vegetables, milk and herbal teas all count toward fluid intake. Caffeinated drinks contribute too, though very large amounts of caffeine can bother sensitive stomachs.

A few gentle habits make consistency easy: keep a bottle where you can see it, drink a glass with each meal, and have water alongside coffee or alcohol. Sipping through the day tends to feel better than forcing large amounts at once.

$_disclaimer''',
    ),
    Article(
      id: 'art-9',
      title: 'Mindful eating: slowing down to feel better',
      topic: ArticleTopic.habits,
      summary:
          'Why eating more slowly and attentively can ease digestion, '
          'improve satisfaction and reduce overeating.',
      readMinutes: 4,
      authorId: 'sp-1',
      body: '''
Digestion begins before the first bite — the sight and smell of food trigger saliva and digestive secretions. Yet many of us eat on autopilot: at the desk, in the car, in front of a screen, finishing meals in minutes without really tasting them. Mindful eating is the practice of bringing attention back to the meal.

Eating quickly has real downsides. Larger, poorly chewed pieces of food make the stomach work harder, and rushed eating often means swallowing extra air, which can contribute to bloating. Speed also outruns your fullness signals: hormones that tell the brain you have had enough take roughly twenty minutes to catch up.

Mindful eating does not require meditation cushions or special rules. It starts with simple mechanics: sit down to eat, take smaller bites, chew thoroughly, and put the fork down between bites now and then. These small frictions naturally slow the meal to a pace your digestion prefers.

Attention is the second ingredient. Try noticing the temperature, texture and flavour of the first few bites, and check in halfway through the meal: am I still hungry, or eating out of momentum? There is no wrong answer — the point is to make the choice conscious.

Reducing distractions helps a lot. You do not need silence at every meal, but screens are particularly good at making food disappear unnoticed. Even one device-free meal a day is a meaningful start.

People who practice eating this way often report more enjoyment from less food, fewer episodes of uncomfortable fullness, and a calmer relationship with eating overall. Like any habit, it builds with repetition, so start with one meal and let it grow.

$_disclaimer''',
    ),
  ];

  @override
  List<SpecialistProfile> listSpecialists() => _specialists;

  @override
  List<Article> listArticles() => _articles;

  @override
  Article? articleById(String id) {
    for (final article in _articles) {
      if (article.id == id) return article;
    }
    return null;
  }

  @override
  SpecialistProfile? specialistById(String id) {
    for (final specialist in _specialists) {
      if (specialist.id == id) return specialist;
    }
    return null;
  }
}

final contentRepositoryProvider =
    Provider<ContentRepository>((ref) => const CuratedContentRepository());

// ─── Merged providers ──────────────────────────────────────────────────────
//
// Each provider prefers live backend data when available, and silently
// falls back to the static curated set when the user is offline or
// unauthenticated. Riverpod re-evaluates them automatically once the async
// fetch completes, so the UI updates without any explicit refresh logic.

/// Remote nutritionists first; static curated profiles as offline fallback.
final specialistsProvider = Provider<List<SpecialistProfile>>((ref) {
  final remote = ref.watch(remoteSpecialistsProvider).valueOrNull;
  if (remote != null && remote.isNotEmpty) return remote;
  return ref.watch(contentRepositoryProvider).listSpecialists();
});

/// Searches remote specialists + static profiles, in that priority order.
final specialistByIdProvider =
    Provider.family<SpecialistProfile?, String>((ref, id) {
  final remote = ref.watch(remoteSpecialistsProvider).valueOrNull ?? [];
  final local = ref.watch(contentRepositoryProvider).listSpecialists();
  for (final s in [...remote, ...local]) {
    if (s.id == id) return s;
  }
  return null;
});

/// Static curated articles + live professional tips merged together.
final articlesProvider = Provider<List<Article>>((ref) {
  final local = ref.watch(contentRepositoryProvider).listArticles();
  final tips = ref.watch(remoteTipsProvider).valueOrNull ?? [];
  return [...local, ...tips];
});

/// Searches merged articles (local + tips).
final articleByIdProvider = Provider.family<Article?, String>((ref, id) {
  final all = ref.watch(articlesProvider);
  for (final a in all) {
    if (a.id == id) return a;
  }
  return null;
});

/// Articles filtered by topic; `null` returns all.
final articlesByTopicProvider =
    Provider.family<List<Article>, ArticleTopic?>((ref, topic) {
  final articles = ref.watch(articlesProvider);
  if (topic == null) return articles;
  return articles.where((a) => a.topic == topic).toList();
});
