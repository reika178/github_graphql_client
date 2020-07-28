import 'package:flutter/material.dart';
import 'package:fluttericon/octicons.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:gql_link/gql_link.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'github_gql/github_queries.data.gql.dart';
import 'github_gql/github_queries.req.gql.dart';

class GitHubSummary extends StatefulWidget {
  GitHubSummary({@required http.Client client})
      : _link = HttpLink(
        'https://api.github.com/graphql',
        httpClient: client,
      );
  final HttpLink _link;
  @override
  _GitHubSummaryState createState() => _GitHubSummyState();
}

class _GitHubSummaryState extends State<GitHubSummary> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext content) {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          labelType: NavigationRailLabelType.selected,
          destinations: [
            NavigationRailDestination(
              icon: Icon(Octicons.repo),
              label: Text('Repositories'),
            ),
            NavigationRailDestination(
              icon: Icon(Octicons.issue_opened),
              label: Text('Assigned Issues'),
            ),
            NavigationRailDestination(
              icon: Icon(Octicons.git_pull_request),
              label: Text('Pull Requests'),
            ),
          ],
        ),
        VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              RepositoriesList(link: widget._link),
              AssignedIssuesList(link: widget._link),
              PullrequestsList(link: widget._link),
            ],
          ),
        ),
      ],
    );
  }
}

class RepositoriesList extends StatefulWidget {
  const RepositoriesList({@required this.link});
    final Link link;
    @override
    _RepositoriesListState createState() => _RepositoriesListState(link: link)
}

class _RepositoriesListState extends State<RepositoriesList> {
  _RepositorieslistState({@required Link link}) {
    _repositories = _retreiveRespositories(link);
  }
  Future<List<$Repositories$viewer$repositories$nodes>> _repositories;

  Future<List<$Repositories$viewer$repositories$nodes>> _retreiveRespositories(
      Link link) async {
        var result = await link.request(Repositories((b) => b..count = 100)).first;
        if (result.errors != null && result.errors.isNotEmpty) {
          throw QueryException(result.errors);
        }
        return $Repositories(result.data).viewer.repositories.nodes;
      }
}