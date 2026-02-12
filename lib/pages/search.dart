import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pikachu/datas/models/site_data.dart';
import 'package:pikachu/providers/app.dart';
import 'package:pikachu/datas/models/site_thumb.dart';
import 'package:pikachu/views/thumb_list_view.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final ThumbListController _thumbListController = ThumbListController();
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
  }

  Future<SiteData<SiteThumb>> _fetchNextPage(Object? offset) async {
    return ref
        .read(activeSiteProvider)
        .searchIllust(keyword: _controller.text, offset: offset);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tag = ModalRoute.of(context)?.settings.arguments as String?;
    if (tag != null) {
      _controller.text = tag;
      _thumbListController.refresh();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _focusNode.hasFocus ? _buildSearch() : _buildResult(),
    );
  }

  Widget _buildSearch() {
    return Container();
  }

  Widget _buildResult() {
    return ThumbListView(
      site: ref.read(activeSiteProvider),
      initial: null,
      onFetch: (offset) => _fetchNextPage(offset),
      controller: _thumbListController,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Consumer(
        builder: (context, ref, child) {
          return Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: Autocomplete(
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                          return TextField(
                            controller: _controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              hintText: '输入关键字或标签',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () => _controller.clear(),
                              ),
                            ),
                            onChanged: (value) {
                              controller.text = value;
                            },
                          );
                        },
                    optionsBuilder: (textEditingValue) async {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      final lastWord = textEditingValue.text.split(' ').last;

                      if (lastWord.isEmpty) {
                        return const Iterable<String>.empty();
                      }

                      final autoCompleteWords = await ref
                          .read(activeSiteProvider)
                          .getAutoCompleteWords(lastWord);
                      if (autoCompleteWords.isNotEmpty) {
                        return autoCompleteWords;
                      }
                      return const Iterable<String>.empty();
                    },
                    onSelected: (String selection) {
                      final currentText = _controller.text;
                      List<String> words = currentText.trim().split(' ');

                      if (words.isNotEmpty) {
                        words[words.length - 1] = selection;
                      } else {
                        words = [selection];
                      }

                      final newText = '${words.join(' ')} ';
                      setState(() {
                        if (!_controller.text.endsWith(' ')) {
                          setState(() {
                            _controller.text = newText;
                          });
                        }
                      });
                    },
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.search, size: 30),
                onPressed: () async {
                  if (_controller.text.isEmpty) {
                    return;
                  }
                  _focusNode.unfocus();
                  await _thumbListController.refresh();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
