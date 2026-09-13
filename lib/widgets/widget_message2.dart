import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/model/message.dart';
import 'package:url_launcher/url_launcher.dart';

/// Parses a message's `media` field — a JSON-encoded list of
/// `{id, file, kind}` maps (see MediaRef) — into displayable items. Returns
/// an empty list for anything malformed instead of throwing, since this
/// renders arbitrary server/local data.
List<Map<String, dynamic>> _mediaItemsOf(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    }
  } catch (_) {}
  return const [];
}

class MessageWidget2 extends StatefulWidget {
  UIMessage? message;
  bool sender;
  bool head;
  /// Called with the chosen feedback (true=useful, false=not useful) when
  /// the user taps a thumb. Only ever passed for AI messages.
  final void Function(bool useful)? onFeedback;
  MessageWidget2({
    Key? key,
    required this.message,
    this.sender = true,
    this.head = false,
    this.onFeedback,
  }) : super(
          key: key,
        );

  @override
  State<MessageWidget2> createState() => MessageWidget2_(
      message: message, sender: sender, head: head, onFeedback: onFeedback);
}

class MessageWidget2_ extends State<MessageWidget2> {
  UIMessage? message;
  bool sender;
  bool head;
  final void Function(bool useful)? onFeedback;

  MessageWidget2_({
    required this.message,
    required this.sender,
    required this.head,
    this.onFeedback,
  });

  Color _color = Colors.transparent;
  Timer timer = Timer(Duration.zero, () {});

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    int messagelength =
        message!.contenu.length >= 36 ? 36 : message!.contenu.length;
    double proportion = (((MediaQuery.of(context).size.width) * 0.6)) / (36);
    double messageSize = (messagelength * proportion) + 50;
    final mediaItems = _mediaItemsOf(message!.media);
    final hasText = message!.contenu.trim().isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;
    // Pick text/icon color from the bubble's own background, not a fixed
    // black/white — a bubble tinted for dark mode still needs light text,
    // and vice versa, regardless of which one sender/receiver happens to be.
    final bubbleTextColor = !sender ? colorScheme.onPrimary : colorScheme.onSurface;
    //print(messagelength);
    return AnimatedContainer(
      // Provide an optional curve to make the animation feel smoother.
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 1000),
      decoration: BoxDecoration(
        color: _color,
      ),
      child: Padding(
        padding: getPadding(
          top: 14,
        ),
        child: head
            ? Container(
                padding: getPadding(
                  top: 12,
                  bottom: 12,
                ),
                width: BodyWidth() - 40,
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Padding(
                  padding: getPadding(
                    left: 38,
                    right: 38,
                    top: 3,
                    bottom: 4,
                  ),
                  child: Text(
                    translator.chatWelcome,
                    maxLines: null,
                    textAlign: TextAlign.center,
                    style: appStyle.H4(color: Colors.grey),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment:
                    sender ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: (MediaQuery.of(context).size.width) * 0.7,
                        minWidth: 60),
                    child: Container(
                      padding: getPadding(
                        left: 5,
                        top: 5,
                        right: 5,
                        bottom: 5,
                      ),
                      margin: getMargin(
                        right: 5,
                        left: 5,
                      ),
                      width: mediaItems.isEmpty ? messageSize : null,
                      decoration: !sender
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: colorScheme.primary)
                          : BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: colorScheme.surfaceContainer),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          for (final item in mediaItems) ...[
                            _MediaAttachment(
                              url: item['file']?.toString() ?? '',
                              kind: item['kind']?.toString() ?? 'unknown',
                              foreground: bubbleTextColor,
                            ),
                            if (hasText) const SizedBox(height: 6),
                          ],
                          if (hasText)
                            GestureDetector(
                              onLongPress: () {
                                Clipboard.setData(
                                        ClipboardData(text: message!.contenu))
                                    .then((value) {
                                  //only if ->
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                        'message copié dans le presse papier'),
                                  ));
                                }); // -> show a notification
                              },
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3.0),
                                  child: Text(message!.contenu,
                                      maxLines: null,
                                      textAlign: TextAlign.left,
                                      style: appStyle.H5(color: bubbleTextColor)),
                                ),
                              ),
                            ),
                          if (message!.relatedArticle != 'null' &&
                              message!.relatedArticle.trim().isNotEmpty)
                            _RelatedArticleCard(
                              raw: message!.relatedArticle,
                              foreground: bubbleTextColor,
                            ),
                          if (onFeedback != null)
                            _FeedbackRow(
                              current: message!.userFeedback,
                              foreground: bubbleTextColor,
                              onFeedback: onFeedback!,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String getDate(num time, {bool hh_mm = false, bool yy_mm = false}) {
    if (hh_mm)
      return DateTime.fromMillisecondsSinceEpoch(time.toInt() * 1000)
          .format('kk:mm');
    if (yy_mm) {
      var days = [
        'Lundi',
        'Mardi',
        'Mercredi',
        'Jeudi',
        'Vendredi',
        'Samedi',
        'Dimanche'
      ];
      var months = [
        'Janvier',
        'Fevrier',
        'Mars',
        'Avril',
        'Mai',
        'Juin',
        'Juillet',
        'Aout',
        'Septembre',
        'Octobre',
        'Novembre',
        'Decembre'
      ];
      String day = DateTime.fromMillisecondsSinceEpoch(time.toInt() * 1000)
          .day
          .toString();
      String dayCalendar = days[
          DateTime.fromMillisecondsSinceEpoch(time.toInt() * 1000).weekday - 1];
      String month = months[
          DateTime.fromMillisecondsSinceEpoch(time.toInt() * 1000).month - 1];
      String year = DateTime.fromMillisecondsSinceEpoch(time.toInt() * 1000)
          .year
          .toString();
      String date = dayCalendar + ', ' + day + ' ' + month + ' ' + year;
      return date;
    }
    String duree = '';
    double actual = DateTime.now().millisecondsSinceEpoch / 1000;
    double periode = actual - time;
    if (periode / 3600 < 1) {
      duree = (periode / 60).floor().toString() + 'min';
    } else if (periode / 3600 < 24) {
      duree = DateTime.fromMillisecondsSinceEpoch(time.toInt() * 1000)
          .format('kk:mm');
    } else
      duree = DateTime.fromMillisecondsSinceEpoch(time.toInt() * 1000)
          .format('MM/dd');
    return duree;
  }
}

/// Dispatches a single media item to the renderer matching its `kind`.
class _MediaAttachment extends StatelessWidget {
  final String url;
  final String kind;
  final Color foreground;

  const _MediaAttachment({
    required this.url,
    required this.kind,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const SizedBox.shrink();
    switch (kind) {
      case 'image':
        return _ImageAttachment(url: url);
      case 'audio':
        return _VoiceNoteBubble(url: url, foreground: foreground);
      default:
        // 'video'/'unknown' — the picker never attaches these today, but
        // don't silently drop a message that has one (e.g. sent from
        // another client) — show something tappable instead of nothing.
        return _UnsupportedAttachmentChip(kind: kind, foreground: foreground);
    }
  }
}

class _ImageAttachment extends StatelessWidget {
  final String url;

  const _ImageAttachment({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: 220,
        height: 220,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          final total = progress.expectedTotalBytes;
          return SizedBox(
            width: 220,
            height: 220,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: total != null
                    ? progress.cumulativeBytesLoaded / total
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stack) => Container(
          width: 220,
          height: 220,
          color: Colors.black12,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }
}

class _UnsupportedAttachmentChip extends StatelessWidget {
  final String kind;
  final Color foreground;

  const _UnsupportedAttachmentChip(
      {required this.kind, required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.attach_file, size: 18, color: foreground),
        const SizedBox(width: 4),
        Text(kind, style: TextStyle(color: foreground, fontSize: 12)),
      ],
    );
  }
}

/// A small "en savoir plus" card for the AI reply's suggested article, if
/// any. [raw] is the JSON-encoded `{id, title, media, link}` map (or absent
/// fields) coming straight off MessageModel.relatedArticle.
class _RelatedArticleCard extends StatelessWidget {
  final String raw;
  final Color foreground;

  const _RelatedArticleCard({required this.raw, required this.foreground});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> article;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const SizedBox.shrink();
      article = decoded.cast<String, dynamic>();
    } catch (_) {
      return const SizedBox.shrink();
    }
    final title = article['title']?.toString() ?? '';
    if (title.isEmpty) return const SizedBox.shrink();
    final link = article['link']?.toString();
    final media = article['media'];
    final photoUrl = media is Map ? media['file']?.toString() : null;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: link == null || link.isEmpty
            ? null
            : () => launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: foreground.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              if (photoUrl != null && photoUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(photoUrl,
                      width: 40, height: 40, fit: BoxFit.cover),
                ),
              if (photoUrl != null && photoUrl.isNotEmpty)
                const SizedBox(width: 8),
              Icon(Icons.article_outlined, size: 18, color: foreground),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: foreground,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}

/// Useful / not-useful thumbs for an AI reply. [current] is
/// MessageModel.userFeedback ('useful' / 'not_useful' / 'none') and drives
/// which thumb, if any, renders as active/filled.
class _FeedbackRow extends StatelessWidget {
  final String current;
  final Color foreground;
  final void Function(bool useful) onFeedback;

  const _FeedbackRow({
    required this.current,
    required this.foreground,
    required this.onFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final isUseful = current == 'useful';
    final isNotUseful = current == 'not_useful';
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            iconSize: 16,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              isUseful ? Icons.thumb_up : Icons.thumb_up_outlined,
              color: foreground.withValues(alpha: isUseful ? 1 : 0.5),
            ),
            onPressed: () => onFeedback(true),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            iconSize: 16,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              isNotUseful ? Icons.thumb_down : Icons.thumb_down_outlined,
              color: foreground.withValues(alpha: isNotUseful ? 1 : 0.5),
            ),
            onPressed: () => onFeedback(false),
          ),
        ],
      ),
    );
  }
}

/// A compact voice-note player: play/pause, a scrub bar, and a position /
/// duration label. Owns its own [AudioPlayer] so playback state never
/// forces a rebuild of the surrounding message list.
class _VoiceNoteBubble extends StatefulWidget {
  final String url;
  final Color foreground;

  const _VoiceNoteBubble({required this.url, required this.foreground});

  @override
  State<_VoiceNoteBubble> createState() => _VoiceNoteBubbleState();
}

class _VoiceNoteBubbleState extends State<_VoiceNoteBubble> {
  final _player = AudioPlayer();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _player.setUrl(widget.url).then((_) {
      if (mounted) setState(() => _ready = true);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<PlayerState>(
            stream: _player.playerStateStream,
            builder: (context, snapshot) {
              final playing = snapshot.data?.playing ?? false;
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: widget.foreground,
                  size: 32,
                ),
                onPressed: !_ready
                    ? null
                    : () => playing ? _player.pause() : _player.play(),
              );
            },
          ),
          const SizedBox(width: 6),
          Expanded(
            child: StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (context, posSnapshot) {
                final position = posSnapshot.data ?? Duration.zero;
                final duration = _player.duration ?? Duration.zero;
                final durationMs = duration.inMilliseconds;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: Slider(
                        value: durationMs > 0
                            ? position.inMilliseconds
                                .clamp(0, durationMs)
                                .toDouble()
                            : 0,
                        max: durationMs > 0 ? durationMs.toDouble() : 1,
                        activeColor: widget.foreground,
                        inactiveColor: widget.foreground.withValues(alpha: 0.3),
                        onChanged: !_ready
                            ? null
                            : (value) =>
                                _player.seek(Duration(milliseconds: value.toInt())),
                      ),
                    ),
                    Text(
                      '${_format(position)} / ${_format(duration)}',
                      style: TextStyle(color: widget.foreground, fontSize: 11),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
