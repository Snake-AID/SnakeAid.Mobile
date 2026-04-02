Bây giờ ta cần dev chức năng Blog cho dự án, ngay màn hình home_screen member có func "Bài viết mới nhất" ta sẽ dev ở đó nhé

các endpoint liên quan:

POST /api/blogs
{
  "title": "string",
  "content": "string",
  "thumbnailUrl": "string",
  "status": "Draft",
  "category": "SnakeKnowledge",
  "tags": [
    "Venomous"
  ],
  "readingTime": 1440
}

GET /api/blogs (GET all)
GET /api/blogs/{id} (Get detail)

PUT /api/blogs/{id}
Delete /api/blogs/{id}

và các PATCH
PATCH /api/blogs/{id}/view
PATCH /api/blogs/{id}/like
PATCH /api/blogs/{id}/like

- Với chức năng này ta sẽ có mặt tham gia của 3 role chính là member, expert, admin
- member có quyền xem  bài viết ở status "Published" giúp tăng lượt xem và có thể thả tương tác cho bài viết
- expert có quyền đăng và thêm/xóa/sửa bài viết, trong màn hình home_screen của expert cũng sẽ có func Blogs nhé
- ở UI expert sẽ có 2 nút Lưu và Đăng bài viết, nếu expert bấm nút Lưu sẽ truyền vào POST status là "Draft", còn nếu expert bấm nút đăng bài viết sẽ truyền status là "PendingApproval", trong các bài viết ở dạng lưu cũng có thể bấm nút "Đăng bài viết" lúc này sẽ gọi PATCH để chuyển status sang "PendingApproval"
- khi bài viết bị từ chối status ="Rejected" thì sẽ hiển thị field rejectionReason để hiển thị lí do
Lưu ý: dev các màn hình liên quan member và expert sao cho phù hợp, về bố cục field "content" tôi cần bạn gen 1 docs để viết design content lên web admin và thiết kế sao cho chuyên nghiệp và phù hợp nhé

Tôi cũng cần 1 file example content để đổ dataTest lên server, data tầm 6 content, chạy lệnh POST

Đây là toàn bộ entity Blog

public class Blog : BaseEntity
    {
        [Key]
        public Guid Id { get; set; }

        [Required]
        [ForeignKey(nameof(Author))]
        public Guid AuthorId { get; set; }

        [Required]
        [StringLength(500)]
        public string Title { get; set; }

        [Required]
        [StringLength(500)]
        public string ThumbnailUrl { get; set; }

        [Required]
        public string Content { get; set; }

        [Required]
        public BlogCategory Category { get; set; }

        [Required]
        public List<BlogTag> Tags { get; set; } = new List<BlogTag>();

        [Required]
        public int ViewCount { get; set; } = 0;

        [Required]
        public int LikeCount { get; set; } = 0;

        [Required]
        public int ReadingTime { get; set; } // in minutes

        [Required]
        public BlogStatus Status { get; set; } = BlogStatus.Draft;

        public string? RejectionReason { get; set; }

        public List<string> LikedViewer { get; set; } = new List<string>();

        // Navigation properties
        public Account Author { get; set; }
    }

    public enum BlogStatus
    {
        Draft = 0,
        PendingApproval = 1,
        Published = 2,
        Rejected = 3,
    }

    public enum BlogCategory
    {
        SnakeKnowledge = 0,
        SnakeSpecies = 1,
        SnakeHealth = 2,
        SnakeFeeding = 3,
        SnakeHabitat = 4,
        Other = 5
    }

    public enum BlogTag
    {
        Venomous = 0,
        NonVenomous = 1,
        Safety = 2,
        WildSnake = 3,
        SnakeCare = 4,
        SnakeBehavior = 5,
        SnakeIdentification = 6,
        SnakeConservation = 7,
        SnakeMyths = 8,
        Other = 9
    }