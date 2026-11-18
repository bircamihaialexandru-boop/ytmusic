import XCTest
@testable import Mooziac

final class YTMClientSearchTests: XCTestCase {

    func testParseTopCardDirectVideo() {
        let json: [String: Any] = [
            "contents": [
                "tabbedSearchResultsRenderer": [
                    "tabs": [
                        [
                            "tabRenderer": [
                                "content": [
                                    "sectionListRenderer": [
                                        "contents": [
                                            [
                                                "musicCardShelfRenderer": [
                                                    "title": ["runs": [["text": "Shape of You"]]],
                                                    "subtitle": ["runs": [["text": "Video • Ed Sheeran • 6.7B views • 4:24"]]],
                                                    "onTap": [
                                                        "watchEndpoint": ["videoId": "JGwWNGJdvx8"]
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]

        let track = YTMClient.parseTopTrack(from: json)
        XCTAssertNotNil(track)
        XCTAssertEqual(track?.videoId, "JGwWNGJdvx8")
        XCTAssertEqual(track?.title, "Shape of You")
    }

    func testParseArtistCardWithTopSongs() {
        let json: [String: Any] = [
            "contents": [
                "tabbedSearchResultsRenderer": [
                    "tabs": [
                        [
                            "tabRenderer": [
                                "content": [
                                    "sectionListRenderer": [
                                        "contents": [
                                            [
                                                "musicCardShelfRenderer": [
                                                    "title": ["runs": [["text": "Queen"]]],
                                                    "subtitle": ["runs": [["text": "Artist • 97.7M monthly audience"]]],
                                                    "buttons": [
                                                        [
                                                            "buttonRenderer": [
                                                                "navigationEndpoint": [
                                                                    "watchEndpoint": [
                                                                        "videoId": "ignored",
                                                                        "playlistId": "RDAObHaAx"
                                                                    ]
                                                                ]
                                                            ]
                                                        ]
                                                    ],
                                                    "contents": [
                                                        [
                                                            "musicResponsiveListItemRenderer": [
                                                                "playlistItemData": ["videoId": "5CLpG1uspBQ"],
                                                                "flexColumns": [
                                                                    [
                                                                        "musicResponsiveListItemFlexColumnRenderer": [
                                                                            "text": ["runs": [["text": "I Want To Break Free"]]]
                                                                        ]
                                                                    ]
                                                                ]
                                                            ]
                                                        ]
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]

        let track = YTMClient.parseTopTrack(from: json)
        XCTAssertNotNil(track)
        XCTAssertEqual(track?.videoId, "5CLpG1uspBQ")
        XCTAssertEqual(track?.title, "I Want To Break Free")
    }

    func testParseShelfRenderer() {
        let json: [String: Any] = [
            "contents": [
                "tabbedSearchResultsRenderer": [
                    "tabs": [
                        [
                            "tabRenderer": [
                                "content": [
                                    "sectionListRenderer": [
                                        "contents": [
                                            [
                                                "musicShelfRenderer": [
                                                    "contents": [
                                                        [
                                                            "musicResponsiveListItemRenderer": [
                                                                "playlistItemData": ["videoId": "BciS5krYL80"],
                                                                "flexColumns": [
                                                                    [
                                                                        "musicResponsiveListItemFlexColumnRenderer": [
                                                                            "text": ["runs": [["text": "Hotel California"]]]
                                                                        ]
                                                                    ],
                                                                    [
                                                                        "musicResponsiveListItemFlexColumnRenderer": [
                                                                            "text": ["runs": [["text": "Eagles • Hotel California"]]]
                                                                        ]
                                                                    ]
                                                                ]
                                                            ]
                                                        ]
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]

        let track = YTMClient.parseTopTrack(from: json)
        XCTAssertNotNil(track)
        XCTAssertEqual(track?.videoId, "BciS5krYL80")
        XCTAssertEqual(track?.title, "Hotel California")
        XCTAssertEqual(track?.artist, "Eagles")
    }

    func testSkipPodcastInFavorOfShelfSong() {
        let json: [String: Any] = [
            "contents": [
                "tabbedSearchResultsRenderer": [
                    "tabs": [
                        [
                            "tabRenderer": [
                                "content": [
                                    "sectionListRenderer": [
                                        "contents": [
                                            [
                                                "musicCardShelfRenderer": [
                                                    "title": ["runs": [["text": "Some Talk Show"]]],
                                                    "subtitle": ["runs": [["text": "Episode • 45 min"]]],
                                                    "onTap": [
                                                        "watchEndpoint": ["videoId": "podcast123"]
                                                    ]
                                                ]
                                            ],
                                            [
                                                "musicShelfRenderer": [
                                                    "contents": [
                                                        [
                                                            "musicResponsiveListItemRenderer": [
                                                                "playlistItemData": ["videoId": "song456"],
                                                                "flexColumns": [
                                                                    [
                                                                        "musicResponsiveListItemFlexColumnRenderer": [
                                                                            "text": ["runs": [["text": "Kesariya"]]]
                                                                        ]
                                                                    ],
                                                                    [
                                                                        "musicResponsiveListItemFlexColumnRenderer": [
                                                                            "text": ["runs": [["text": "Arijit Singh • Brahmastra"]]]
                                                                        ]
                                                                    ]
                                                                ]
                                                            ]
                                                        ]
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]

        let track = YTMClient.parseTopTrack(from: json)
        XCTAssertNotNil(track)
        XCTAssertEqual(track?.videoId, "song456")
        XCTAssertEqual(track?.title, "Kesariya")
        XCTAssertEqual(track?.artist, "Arijit Singh")
    }

    func testEmptyResponseReturnsNil() {
        let json: [String: Any] = [:]
        let track = YTMClient.parseTopTrack(from: json)
        XCTAssertNil(track)
    }

    func testParseSearchResultsTracksAndMetadata() {
        let json: [String: Any] = [
            "contents": [
                "tabbedSearchResultsRenderer": [
                    "tabs": [
                        [
                            "tabRenderer": [
                                "content": [
                                    "sectionListRenderer": [
                                        "contents": [
                                            [
                                                "musicCardShelfRenderer": [
                                                    "title": ["runs": [["text": "Blinding Lights"]]],
                                                    "subtitle": ["runs": [["text": "Song • The Weeknd • After Hours • 3:20"]]],
                                                    "thumbnail": [
                                                        "musicThumbnailRenderer": [
                                                            "thumbnail": [
                                                                "thumbnails": [
                                                                    ["url": "https://lh3.googleusercontent.com/small"],
                                                                    ["url": "https://lh3.googleusercontent.com/large"]
                                                                ]
                                                            ]
                                                        ]
                                                    ],
                                                    "onTap": [
                                                        "watchEndpoint": ["videoId": "fHI8X4OXluQ"]
                                                    ]
                                                ]
                                            ],
                                            [
                                                "musicShelfRenderer": [
                                                    "contents": [
                                                        [
                                                            "musicResponsiveListItemRenderer": [
                                                                "playlistItemData": ["videoId": "fHI8X4OXluQ"],
                                                                "flexColumns": [
                                                                    [
                                                                        "musicResponsiveListItemFlexColumnRenderer": [
                                                                            "text": ["runs": [["text": "Blinding Lights"]]]
                                                                        ]
                                                                    ],
                                                                    [
                                                                        "musicResponsiveListItemFlexColumnRenderer": [
                                                                            "text": ["runs": [["text": "The Weeknd • 3:20"]]]
                                                                        ]
                                                                    ]
                                                                ]
                                                            ]
                                                        ],
                                                        [
                                                            "musicResponsiveListItemRenderer": [
                                                                "playlistItemData": ["videoId": "4NRXx6U8ABQ"],
                                                                "flexColumns": [
                                                                    [
                                                                        "musicResponsiveListItemFlexColumnRenderer": [
                                                                            "text": ["runs": [["text": "Blinding Lights (Official Audio)"]]]
                                                                        ]
                                                                    ],
                                                                    [
                                                                        "musicResponsiveListItemFlexColumnRenderer": [
                                                                            "text": ["runs": [["text": "Song • The Weeknd • After Hours • 3:22"]]]
                                                                        ]
                                                                    ]
                                                                ]
                                                            ]
                                                        ],
                                                        [
                                                            "musicResponsiveListItemRenderer": [
                                                                "playlistItemData": ["videoId": "pod999"],
                                                                "flexColumns": [
                                                                    [
                                                                        "musicResponsiveListItemFlexColumnRenderer": [
                                                                            "text": ["runs": [["text": "Daily Podcast"]]]
                                                                        ]
                                                                    ],
                                                                    [
                                                                        "musicResponsiveListItemFlexColumnRenderer": [
                                                                            "text": ["runs": [["text": "Podcast • 42 min"]]]
                                                                        ]
                                                                    ]
                                                                ]
                                                            ]
                                                        ]
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]

        let parsed = YTMClient.parseSearchResults(from: json)
        XCTAssertEqual(parsed.tracks.count, 2)
        XCTAssertEqual(parsed.tracks[0].videoId, "fHI8X4OXluQ")
        XCTAssertEqual(parsed.tracks[0].title, "Blinding Lights")
        XCTAssertEqual(parsed.tracks[0].artist, "The Weeknd")
        XCTAssertEqual(parsed.tracks[0].album, "After Hours")
        XCTAssertEqual(parsed.tracks[0].duration, "3:20")
        XCTAssertEqual(parsed.tracks[0].artworkUrl, "https://lh3.googleusercontent.com/large")
        XCTAssertEqual(parsed.tracks[1].videoId, "4NRXx6U8ABQ")
        XCTAssertEqual(parsed.tracks[1].artworkUrl, "https://i.ytimg.com/vi/4NRXx6U8ABQ/hqdefault.jpg")
    }

    func testParseSearchResultsPlaylistsAndSingleColumnLayout() {
        let json: [String: Any] = [
            "contents": [
                "singleColumnBrowseResultsRenderer": [
                    "tabs": [
                        [
                            "tabRenderer": [
                                "content": [
                                    "sectionListRenderer": [
                                        "contents": [
                                            [
                                                "itemSectionRenderer": [
                                                    "contents": [
                                                        [
                                                            "musicResponsiveListItemRenderer": [
                                                                "navigationEndpoint": [
                                                                    "browseEndpoint": [
                                                                        "browseId": "VLPLabc123",
                                                                        "browseEndpointContextSupportedConfigs": [
                                                                            "browseEndpointContextMusicConfig": [
                                                                                "pageType": "MUSIC_PAGE_TYPE_PLAYLIST"
                                                                            ]
                                                                        ]
                                                                    ]
                                                                ],
                                                                "thumbnail": [
                                                                    "musicThumbnailRenderer": [
                                                                        "thumbnail": [
                                                                            "thumbnails": [
                                                                                ["url": "https://example.com/pl_cover.jpg"]
                                                                            ]
                                                                        ]
                                                                    ]
                                                                ],
                                                                "flexColumns": [
                                                                    [
                                                                        "musicResponsiveListItemFlexColumnRenderer": [
                                                                            "text": ["runs": [["text": "Late Night Synthwave"]]]
                                                                        ]
                                                                    ],
                                                                    [
                                                                        "musicResponsiveListItemFlexColumnRenderer": [
                                                                            "text": ["runs": [["text": "Playlist • Mihai • 24 songs"]]]
                                                                        ]
                                                                    ]
                                                                ]
                                                            ]
                                                        ]
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]

        let parsed = YTMClient.parseSearchResults(from: json)
        XCTAssertTrue(parsed.tracks.isEmpty)
        XCTAssertEqual(parsed.playlists.count, 1)
        XCTAssertEqual(parsed.playlists[0].playlistId, "PLabc123")
        XCTAssertEqual(parsed.playlists[0].browseId, "VLPLabc123")
        XCTAssertEqual(parsed.playlists[0].title, "Late Night Synthwave")
        XCTAssertEqual(parsed.playlists[0].author, "Mihai")
        XCTAssertEqual(parsed.playlists[0].trackCountText, "24 songs")
        XCTAssertEqual(parsed.playlists[0].artworkUrl, "https://example.com/pl_cover.jpg")
    }
}
