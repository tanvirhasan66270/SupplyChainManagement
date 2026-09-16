package com.example.SCM.repository;

import com.example.SCM.entity.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {
    // Fetch only the messages targeted for this specific logged-in user
    List<Message> findByRecipientIdOrderByCreatedAtDesc(String recipientId);

    @Query("SELECT m FROM Message m WHERE " +
           "(m.senderId = :user1 AND m.recipientId = :user2) OR " +
           "(m.senderId = :user2 AND m.recipientId = :user1) " +
           "ORDER BY m.createdAt ASC")
    List<Message> findChatHistory(@Param("user1") String user1, @Param("user2") String user2);
}