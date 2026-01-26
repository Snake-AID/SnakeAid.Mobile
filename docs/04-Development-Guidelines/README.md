# 📖 README - Development Guidelines

## 📁 Tài liệu trong thư mục này

### 1. **AI-Agent-Rules.md** ⭐️ QUAN TRỌNG NHẤT
> **Dành cho:** AI/Bot khi implement code

**Mục đích:**
- Quy tắc BẮT BUỘC cho AI phải follow khi implement
- Workflow từng bước chi tiết không được bỏ qua
- Validation checklist trước khi hoàn thành
- Template response chuẩn

**Khi nào dùng:**
- ✅ LUÔN LUÔN khi AI implement bất kỳ task nào
- ✅ Trước khi bắt đầu code → Đọc rules
- ✅ Trong khi code → Check từng bước
- ✅ Sau khi code → Validate theo checklist

---

### 2. **Implementation-Checklist.md**
> **Dành cho:** Developers & AI

**Mục đích:**
- Checklist đầy đủ để không bỏ sót file/function
- Template checklist cho từng feature
- Common mistakes cần tránh
- Review checklist trước commit

**Khi nào dùng:**
- ✅ Khi bắt đầu feature mới → Copy template checklist
- ✅ Trong quá trình implement → Tick từng item
- ✅ Trước khi commit → Final review

---

### 3. **Coding-Standards.md**
> **Dành cho:** Developers & Code Review

**Mục đích:**
- Naming conventions chi tiết
- Code structure chuẩn cho từng layer
- Anti-patterns phải tránh
- Best practices

**Khi nào dùng:**
- ✅ Khi code → Reference naming
- ✅ Khi review code → Check standards
- ✅ Khi onboard developer mới → Đọc toàn bộ

---

### 4. **Quick-Reference.md**
> **Dành cho:** Developers cần tham khảo nhanh

**Mục đích:**
- Code templates có thể copy ngay
- Common UI patterns
- Validation examples
- Debugging tips
- Useful snippets

**Khi nào dùng:**
- ✅ Cần template code → Copy & customize
- ✅ Quên syntax → Quick lookup
- ✅ Debug issue → Check debugging section

---

## 🎯 Workflow Sử Dụng

### **Cho AI/Bot:**

```
1. Nhận task từ user
   ↓
2. ĐỌC AI-Agent-Rules.md
   ↓
3. Follow STEP-BY-STEP workflow
   ↓
4. Tham khảo Coding-Standards.md & Quick-Reference.md khi cần
   ↓
5. Validate theo checklist trong AI-Agent-Rules.md
   ↓
6. Report theo template
```

### **Cho Developer:**

```
1. Nhận task/feature mới
   ↓
2. Đọc Implementation-Checklist.md → Copy template
   ↓
3. Tham khảo Quick-Reference.md → Get templates
   ↓
4. Code theo Coding-Standards.md
   ↓
5. Tick checklist items khi hoàn thành
   ↓
6. Review theo Coding-Standards.md
   ↓
7. Commit
```

---

## 📋 Priority Order

### **Độ ưu tiên đọc:**

1. **🔴 CRITICAL** - AI-Agent-Rules.md
   - AI phải đọc và follow 100%
   - Không được bỏ qua bất kỳ bước nào

2. **🟠 HIGH** - Implementation-Checklist.md
   - Đảm bảo không bỏ sót
   - Template để track progress

3. **🟡 MEDIUM** - Coding-Standards.md
   - Reference khi cần
   - Code review standards

4. **🟢 LOW** - Quick-Reference.md
   - Quick lookup
   - Copy templates

---

## 🚀 Quick Start

### **Tôi là AI/Bot, tôi phải làm gì?**

1. **Mở file:** [AI-Agent-Rules.md](AI-Agent-Rules.md)
2. **Đọc:** Section "MANDATORY PRE-IMPLEMENTATION CHECKLIST"
3. **Follow:** Step-by-step workflow
4. **Validate:** Trước khi report done

### **Tôi là Developer, tôi bắt đầu thế nào?**

1. **Mở file:** [Implementation-Checklist.md](Implementation-Checklist.md)
2. **Copy:** Template checklist cho feature của bạn
3. **Tham khảo:** [Quick-Reference.md](Quick-Reference.md) để lấy code templates
4. **Code:** Theo [Coding-Standards.md](Coding-Standards.md)

---

## 🔍 Tìm Nội Dung Cụ Thể

### **Tôi muốn biết cách đặt tên:**
→ [Coding-Standards.md](Coding-Standards.md) - Section "NAMING CONVENTIONS"

### **Tôi cần template cho Model:**
→ [Quick-Reference.md](Quick-Reference.md) - Section "1. Model Template"

### **Tôi muốn checklist đầy đủ:**
→ [Implementation-Checklist.md](Implementation-Checklist.md)

### **AI cần biết workflow:**
→ [AI-Agent-Rules.md](AI-Agent-Rules.md) - Section "STEP-BY-STEP IMPLEMENTATION WORKFLOW"

### **Tôi muốn biết validation nào:**
→ [Quick-Reference.md](Quick-Reference.md) - Section "COMMON VALIDATIONS"

### **Tôi muốn biết cách handle error:**
→ [Coding-Standards.md](Coding-Standards.md) - Section "ERROR HANDLING"

---

## ✅ Checklist Onboarding

### **Cho Developer Mới:**

- [ ] Đọc [Coding-Standards.md](Coding-Standards.md) - Toàn bộ
- [ ] Đọc [Implementation-Checklist.md](Implementation-Checklist.md) - Hiểu workflow
- [ ] Bookmark [Quick-Reference.md](Quick-Reference.md) - Để tham khảo
- [ ] Review existing code trong `lib/core/` và `lib/features/`
- [ ] Implement 1 feature nhỏ để practice

### **Cho AI/Bot Setup:**

- [ ] Load [AI-Agent-Rules.md](AI-Agent-Rules.md) vào context
- [ ] Understand MANDATORY rules
- [ ] Test với 1 simple task
- [ ] Verify output theo checklist
- [ ] Ready for production use

---

## 🎓 Training Materials

### **Level 1: Beginner**
1. Đọc Coding-Standards.md
2. Copy code từ Quick-Reference.md
3. Implement simple widget/screen

### **Level 2: Intermediate**
1. Đọc Implementation-Checklist.md
2. Implement complete feature (Model → Screen)
3. Self-review theo checklist

### **Level 3: Advanced**
1. Understand AI-Agent-Rules.md
2. Train AI/Bot với rules
3. Review & optimize existing code

---

## 📞 Khi Cần Giúp Đỡ

### **Không biết bắt đầu từ đâu?**
→ Đọc Quick-Reference.md section "IMPLEMENTATION WORKFLOW"

### **Code không work?**
→ Check Coding-Standards.md section "COMMON MISTAKES"

### **AI implement sai?**
→ Verify AI-Agent-Rules.md có được follow đúng không

### **Quên cú pháp?**
→ Quick-Reference.md có tất cả templates

---

## 🔄 Update History

### Version 1.0 - 2026-01-26
- ✅ Initial creation
- ✅ AI-Agent-Rules.md - Complete workflow for AI
- ✅ Implementation-Checklist.md - Complete checklist
- ✅ Coding-Standards.md - Comprehensive standards
- ✅ Quick-Reference.md - Templates and snippets

---

## 📝 Contribution Guidelines

### **Khi update rules:**

1. Update file tương ứng
2. Sync changes across related files
3. Update version history
4. Test với AI/Bot
5. Commit với message rõ ràng

---

## 🎯 Goals

1. **Consistency:** Code nhất quán trong toàn dự án
2. **Quality:** Không bỏ sót, không anti-pattern
3. **Efficiency:** AI/Developer work nhanh hơn
4. **Maintainability:** Dễ maintain và scale
5. **Onboarding:** Developer mới nắm bắt nhanh

---

**🌟 Remember:** Rules được tạo ra để giúp code tốt hơn, không phải để gò bó. Nếu có case đặc biệt, discuss với team!
