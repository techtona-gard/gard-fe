import 'package:flutter/material.dart';
import 'package:gard/constants/app_colors.dart';
import 'package:gard/pages/education_article_page.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edukasi Lambung',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkAccent)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.darkAccent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.softAccent.withOpacity(0.5)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          // Section header
          const Text(
            'Pilih Topik',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Article cards
          ...educationArticles.map((article) => _buildArticleCard(context, article)),
        ],
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, EducationArticle article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EducationArticlePage(article: article),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.softAccent.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: Icon(article.icon, color: AppColors.softAccent, size: 22),
              ),
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.darkAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 12, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        article.readTime,
                        style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Chevron
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.softAccent.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
